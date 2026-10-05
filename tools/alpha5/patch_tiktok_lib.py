#!/usr/bin/env python3
"""Generate a private SDK 36 TTMod overlay; do not distribute the supplied library.

Disables only the optional LSPlant ClassLinker visibility symbol lookups.
Reference: https://github.com/LSPosed/LSPlant/issues/179
"""
import argparse
import hashlib
import json
import struct
import zipfile
from pathlib import Path

INSPECTED_SHA256 = '45ef87b1038007c9e5692d815500617837d48da17065431cc63a6d1289b5825b'
SYMBOLS = (
    b'_ZN3art11ClassLinker26VisiblyInitializedCallback29AdjustThreadVisibilityCounterEPNS_6ThreadEl',
    b'_ZN3art11ClassLinker26VisiblyInitializedCallback22MarkVisiblyInitializedEPNS_6ThreadE',
)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input_library', type=Path)
    parser.add_argument('output_module', type=Path)
    args = parser.parse_args()
    data = args.input_library.read_bytes()
    if hashlib.sha256(data).hexdigest() != INSPECTED_SHA256:
        parser.error('Library differs from the inspected TTMod build')
    if data[:6] != b'\x7fELF\x02\x01' or struct.unpack_from('<H', data, 18)[0] != 183:
        parser.error('Expected little-endian ARM64 ELF')
    changes = []
    for symbol in SYMBOLS:
        if data.count(symbol + b'\x00') != 1:
            parser.error('Optional lookup symbol is missing or ambiguous')
        offset = data.index(symbol)
        # Same-length invalid C++ symbol: resolver fails and Init continues.
        data = data[:offset] + b'_VN' + data[offset + 3:]
        changes.append({'offset': offset, 'disabled_lookup': symbol.decode()})
    digest = hashlib.sha256(data).hexdigest()
    service = f'''#!/system/bin/sh
set -eu
[ "$(getprop ro.build.version.sdk)" = 36 ] || exit 0
vst_mod=${{0%/*}}
vst_wait=0
while [ "$(getprop sys.boot_completed)" != 1 ]; do
    vst_wait=$((vst_wait + 1))
    [ "$vst_wait" -lt 120 ] || exit 1
    sleep 2
done
vst_apk=$(pm path com.zhiliaoapp.musically | head -n 1)
case "$vst_apk" in package:/data/app/*/base.apk) vst_apk=${{vst_apk#package:}} ;; *) exit 0 ;; esac
vst_lib=${{vst_apk%/*}}/lib/arm64/libttmod.so
[ -f "$vst_lib" ] || exit 0
vst_hash=$(sha256sum "$vst_lib"); vst_hash=${{vst_hash%% *}}
[ "$vst_hash" != {digest} ] || exit 0
if [ "$vst_hash" != {INSPECTED_SHA256} ]; then
    echo 'TTMod build changed: compatibility overlay skipped' >&2
    exit 1
fi
/data/adb/magisk/busybox mount -o bind "$vst_mod/libttmod.so" "$vst_lib"
'''
    with zipfile.ZipFile(args.output_module, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('module.prop', 'id=vst_tiktok_art_fix\nname=VST TTMod Android 16 compatibility\nversion=Alpha5\nversionCode=500\nauthor=ValentinStars\ndescription=Skips two optional LSPlant visibility lookups in the inspected TTMod build. SDK 36 only.\n')
        z.writestr('customize.sh', 'set_perm_recursive "$MODPATH" 0 0 0755 0644\nset_perm "$MODPATH/service.sh" 0 0 0755\n')
        z.writestr('service.sh', service)
        z.writestr('libttmod.so', data)
        z.writestr('patch.json', json.dumps({'input_sha256': INSPECTED_SHA256, 'output_sha256': digest, 'changes': changes}, indent=2))
    print(digest)

if __name__ == '__main__':
    main()
