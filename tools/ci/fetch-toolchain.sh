#!/usr/bin/env bash
set -euo pipefail
vst_target=${1:?Specify toolchain directory}
vst_archive=$(mktemp)
trap 'rm -f "$vst_archive"' EXIT
vst_url=https://github.com/Neutron-Toolchains/clang-build-catalogue/releases/download/05012024/neutron-clang-05012024.tar.zst
curl --fail --location --retry 3 --output "$vst_archive" "$vst_url"
printf '%s  %s\n' c0f062a39bc70665f1e69cb6cc5e7fc63e8701b5bdb9b682831e48659ab40b5a "$vst_archive" | sha256sum -c -
mkdir -p "$vst_target"
tar --zstd -xf "$vst_archive" -C "$vst_target"
"$vst_target/bin/clang" --version | head -n 1 | tee "$vst_target/VST_COMPILER.txt"
grep -q 'Neutron clang version 18\.' "$vst_target/VST_COMPILER.txt"
