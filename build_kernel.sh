#!/usr/bin/env bash
set -e

TOPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTDIR="$TOPDIR/out"
TOOLCHAIN_DIR="$TOPDIR/Neutron_Clang_18"
DEFCONFIG="vstnh_defconfig"
KERNEL_VERSION="Alpha2"

echo "============================================================"
echo "⚡ VSTHunterKernel (VSTnh) — Automated Build System"
echo "👑 Author: Valentin Stars (vstbio.t.me)"
echo "📱 Device: Samsung Galaxy A51 (SM-A515F / universal9611)"
echo "🎯 Version: $KERNEL_VERSION"
echo "============================================================"

# Check and download Neutron Clang if missing
if [ ! -d "$TOOLCHAIN_DIR/bin" ]; then
    echo "[*] Neutron Clang toolchain not found. Downloading..."
    mkdir -p "$TOOLCHAIN_DIR"
    cd "$TOOLCHAIN_DIR"
    curl -LO "https://github.com/Neutron-Toolchains/antman/raw/main/antman"
    chmod +x antman
    ./antman -S
    ./antman --patch=glibc
    cd "$TOPDIR"
fi

export PATH="$TOOLCHAIN_DIR/bin:$PATH"

# Check compiler version
echo "[*] Using compiler: $(clang --version | head -n 1)"

mkdir -p "$OUTDIR"

# Generate defconfig
echo "[*] Generating configuration from $DEFCONFIG..."
make O="$OUTDIR" ARCH=arm64 HOSTCC=clang HOSTCXX=clang++ CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 "$DEFCONFIG"

# Build Kernel Image
echo "[*] Compiling Kernel Image..."
make -j$(nproc) O="$OUTDIR" ARCH=arm64 HOSTCC=clang HOSTCXX=clang++ CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 Image

if [ ! -f "$OUTDIR/arch/arm64/boot/Image" ]; then
    echo "[-] ERROR: Kernel Image compilation failed!"
    exit 1
fi

echo "[+] Kernel Image compiled successfully!"

# Build Modules
echo "[*] Building Kernel Modules..."
make -j$(nproc) O="$OUTDIR" ARCH=arm64 HOSTCC=clang HOSTCXX=clang++ CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 modules || true

# Package AnyKernel3 Zip
echo "[*] Packaging AnyKernel3 Flashable Zip..."
cp "$OUTDIR/arch/arm64/boot/Image" "$TOPDIR/AnyKernel3/Image"
cd "$TOPDIR/AnyKernel3"
ZIP_NAME="VSTHunterKernel-A51-NetHunter-VST-${KERNEL_VERSION}.zip"
zip -r9 "$OUTDIR/$ZIP_NAME" * -x "*.zip"
rm -f "$TOPDIR/AnyKernel3/Image"
cd "$TOPDIR"

echo "============================================================"
echo "[+] BUILD SUCCESSFUL!"
echo "[+] Flashable Zip: $OUTDIR/$ZIP_NAME"
echo "============================================================"
