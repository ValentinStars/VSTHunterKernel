#!/usr/bin/env bash
set -euo pipefail

VST_TOPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VST_BUILD_DIR="${VST_OUT_DIR:-$VST_TOPDIR/out_alpha5}"
VST_COMPILER_DIR="${VST_TOOLCHAIN_DIR:-$VST_TOPDIR/Neutron_Clang_18}"
VST_JOB_COUNT="${VST_JOBS:-$(nproc)}"
VST_DEFCONFIG="${VST_CONFIG:-vstnh_defconfig}"
VST_RELEASE="Alpha5"

if [[ ! -x "$VST_COMPILER_DIR/bin/clang" ]]; then
    echo "Clang toolchain missing: $VST_COMPILER_DIR/bin/clang" >&2
    echo 'Set VST_TOOLCHAIN_DIR to the inspected Neutron Clang 18 installation.' >&2
    exit 1
fi
export PATH="$VST_COMPILER_DIR/bin:$PATH"
mkdir -p "$VST_BUILD_DIR"
VST_MAKE_ARGS=(O="$VST_BUILD_DIR" ARCH=arm64 LOCALVERSION=
    HOSTCC=clang HOSTCXX=clang++ HOSTLDFLAGS=-fuse-ld=lld
    CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm
    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip
    CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    LLVM=1 LLVM_IAS=1)

cd "$VST_TOPDIR"
(cd firmware && sha256sum -c alpha5-firmware.sha256)
clang --version | head -n 1
make "${VST_MAKE_ARGS[@]}" "$VST_DEFCONFIG"
make -j"$VST_JOB_COUNT" "${VST_MAKE_ARGS[@]}" Image modules
[[ -s "$VST_BUILD_DIR/arch/arm64/boot/Image" ]]
VST_STAGE="$(mktemp -d "$VST_BUILD_DIR/anykernel.XXXXXX")"
trap 'rm -rf -- "$VST_STAGE"' EXIT
cp -a "$VST_TOPDIR/AnyKernel3/." "$VST_STAGE/"
cp "$VST_BUILD_DIR/arch/arm64/boot/Image" "$VST_STAGE/Image"
VST_ZIP="$VST_BUILD_DIR/VSTHunterKernel-A51-NetHunter-VST-$VST_RELEASE.zip"
rm -f -- "$VST_ZIP"
(cd "$VST_STAGE" && zip -qr9 "$VST_ZIP" . -x '*.zip' '.git/*')
sha256sum "$VST_ZIP"
echo "Kernel and modules built successfully: $VST_ZIP"
