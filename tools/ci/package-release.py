#!/usr/bin/env python3
"""Package public build outputs; exclude all phone-specific data and ROM overlays."""
import hashlib
import os
import shutil
import subprocess
import zipfile
from pathlib import Path
root = Path(__file__).resolve().parents[2]
build = Path(os.environ.get('VST_OUT_DIR', root / 'out_alpha5'))
dest = build / 'release'
dest.mkdir(exist_ok=True)
kernel = build / 'VSTHunterKernel-A51-NetHunter-VST-Alpha5.zip'
assert kernel.stat().st_size > 1_000_000
shutil.copy2(kernel, dest / kernel.name)
shutil.copy2(build / 'arch/arm64/boot/Image', dest / 'Image')
shutil.copy2(build / '.config', dest / 'effective.config')
with zipfile.ZipFile(dest / 'VST-Magisk-Modules-Alpha5.zip', 'w', zipfile.ZIP_STORED) as z:
    modules = sorted((root / 'magisk_release_zips').glob('*.zip'))
    assert len(modules) == 9
    for f in modules:
        with zipfile.ZipFile(f) as source:
            assert source.testzip() is None
        z.write(f, f.name)
with zipfile.ZipFile(dest / 'VST-Alpha5-Kernel-Modules.zip', 'w', zipfile.ZIP_DEFLATED) as z:
    for f in [build / 'drivers/net/can/slcan.ko', build / 'net/bridge/br_netfilter.ko']:
        assert f.stat().st_size > 0
        assert b'4.14.364-NetHunter-VST-Alpha5 SMP' in f.read_bytes()
        z.write(f, f.name)
with zipfile.ZipFile(dest / 'VST-Alpha5-Helpers-Source.zip', 'w', zipfile.ZIP_DEFLATED) as z:
    sources = subprocess.check_output(['git','ls-files','tools/alpha5','tools/power-audit','tools/rom','docs'],cwd=root,text=True).splitlines()
    for name in sources:
        f=root/name
        if f.is_file(): z.write(f,name)
    z.write(root / 'RELEASE_NOTES_ALPHA5.md', 'RELEASE_NOTES_ALPHA5.md')
commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
compiler = subprocess.check_output([os.environ['VST_TOOLCHAIN_DIR'] + '/bin/clang', '--version'], text=True)
(dest / 'BUILD_INFO.txt').write_text(f'Source commit: {commit}\nKernel: 4.14.364-NetHunter-VST-Alpha5\n'
    'Target: SM-A515F / universal9611\nToolchain archive: neutron-clang-05012024\n'
    'Toolchain SHA256: c0f062a39bc70665f1e69cb6cc5e7fc63e8701b5bdb9b682831e48659ab40b5a\n'
    'Build outputs have not been boot-tested by CI. ROM overlays require local inputs.\n' + compiler)
files = sorted(f for f in dest.iterdir() if f.is_file() and f.name != 'SHA256SUMS')
(dest / 'SHA256SUMS').write_text(''.join(hashlib.sha256(f.read_bytes()).hexdigest() + '  ' + f.name + '\n' for f in files))
notes = root / 'RELEASE_NOTES_ALPHA5.md'
(build / 'CI_RELEASE_NOTES.md').write_text(f'# Alpha5 CI build\n\nSource: `{commit}`.\n\n'
    'Built through the manually triggered workflow. Compilation and packaging checks passed; '
    'this build is a prerelease and has not been boot-tested by the runner. '
    'Do not interpret the historical Alpha5 session tests as tests of this particular binary.\n\n'
    'Includes AnyKernel ZIP, raw Image, matching modules, effective config, Magisk bundle, helper sources and SHA256SUMS. '
    'Evolution services.jar and TTMod compatibility overlays are generated locally, not bundled.\n\n' + notes.read_text())
print(dest)
