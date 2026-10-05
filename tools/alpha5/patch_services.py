#!/usr/bin/env python3
"""Build a local Magisk overlay for the observed Evolution X package-filter recursion.

The stock ROM jar is supplied locally and never included in this repository.
Install dependency: pip install androguard==4.1.3
"""
import argparse
import hashlib
import json
import struct
import zipfile
import zlib
from pathlib import Path

from loguru import logger
logger.remove()
from androguard.core.dex import DEX

CLASS = 'Lcom/android/server/pm/ComputerEngine;'
METHOD = 'canHideApp'
SIGNATURE = '(I Ljava/lang/String;)Z'


def patch_dex(data):
    dex = DEX(data)
    matches = [m for c in dex.get_classes() if c.get_name() == CLASS
               for m in c.get_methods()
               if m.get_name() == METHOD and m.get_descriptor() == SIGNATURE]
    if not matches:
        return None
    if len(matches) != 1:
        raise ValueError('Ambiguous target method')
    code = matches[0].get_code()
    if code is None or code.get_tries_size() or code.get_registers_size() < 1:
        raise ValueError('Unsupported target code layout')
    instructions = list(matches[0].get_instructions())
    if not any('getNameForUid(I)' in i.get_output() for i in instructions):
        raise ValueError('Target does not contain the observed recursive UID lookup')
    patched = bytearray(data)
    start = code.get_off() + 16
    if code.get_insns_size() < 2:
        raise ValueError('Target method is too short')
    # const/4 v0, 0; return v0. All method offsets and file sizes stay intact.
    patched[start:start + 4] = b'\x12\x00\x0f\x00'
    patched[12:32] = hashlib.sha1(patched[32:]).digest()
    struct.pack_into('<I', patched, 8, zlib.adler32(patched[12:]) & 0xffffffff)
    verified = DEX(bytes(patched))
    method = next(m for c in verified.get_classes() if c.get_name() == CLASS
                  for m in c.get_methods() if m.get_name() == METHOD
                  and m.get_descriptor() == SIGNATURE)
    first = list(method.get_instructions())[:2]
    if [i.get_name() for i in first] != ['const/4', 'return']:
        raise ValueError('Patched method verification failed')
    return bytes(patched)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('services_jar', type=Path)
    parser.add_argument('output_zip', type=Path)
    parser.add_argument('--expected-sha256', required=True)
    args = parser.parse_args()
    original = args.services_jar.read_bytes()
    digest = hashlib.sha256(original).hexdigest()
    if digest != args.expected_sha256:
        parser.error('Input ROM jar hash differs from the inspected backup')
    contents = {}
    changed = []
    with zipfile.ZipFile(args.services_jar) as source:
        for entry in source.infolist():
            data = source.read(entry)
            if entry.filename.endswith('.dex'):
                result = patch_dex(data)
                if result is not None:
                    data = result
                    changed.append(entry.filename)
            contents[entry.filename] = data
    if len(changed) != 1:
        parser.error(f'Expected exactly one patched DEX, got {changed}')
    import io
    jar = io.BytesIO()
    with zipfile.ZipFile(jar, 'w', zipfile.ZIP_STORED) as output:
        for name, data in contents.items():
            output.writestr(name, data)
    module = '''id=vst_evolution_pm_fix
name=VST Evolution package filter fix
version=Alpha5
versionCode=5
author=ValentinStars
description=Disables ROM app hiding to prevent recursive UID lookup crashing system_server. For the inspected Evolution ROM only.
'''
    manifest = {'input_sha256': digest, 'patched_dex': changed,
                'output_sha256': hashlib.sha256(jar.getvalue()).hexdigest(),
                'feature_disabled': 'Evolution package hiding (canHideApp)'}
    args.output_zip.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(args.output_zip, 'w', zipfile.ZIP_DEFLATED) as output:
        output.writestr('module.prop', module)
        output.writestr('system/framework/services.jar', jar.getvalue())
        # Reject precompiled code from the unpatched jar; ART falls back to DEX.
        for extension in ('art', 'odex', 'vdex'):
            output.writestr('system/framework/oat/arm64/services.' + extension, b'')
        output.writestr('patch-manifest.json', json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(manifest, indent=2))


if __name__ == '__main__':
    main()
