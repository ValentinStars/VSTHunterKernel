#!/usr/bin/env bash
set -e

TOPDIR="/run/media/valentin_stars/linux/android_kernel_samsung_universal9611"
OUTDIR="$TOPDIR/out_alpha2"
TOOLCHAIN="$TOPDIR/Neutron_Clang_18/bin"
LOGFILE="/run/media/valentin_stars/linux/build.log"
STATUSFILE="/run/media/valentin_stars/linux/build_status.txt"
SDCARD="/run/media/valentin_stars/VST"

echo "BUILDING" > "$STATUSFILE"
export PATH="$TOOLCHAIN:$PATH"

cd "$TOPDIR"

echo "=== VSTHunterKernel (VSTnh) Alpha2 Build Started: $(date) ===" > "$LOGFILE"

# Prepare defconfig if out_alpha2/.config doesn't exist
if [ ! -f "$OUTDIR/.config" ]; then
    echo "=== Generating defconfig for Alpha2 ===" >> "$LOGFILE"
    make O="$OUTDIR" ARCH=arm64 HOSTCC=clang HOSTCXX=clang++ CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 vstnh_defconfig >> "$LOGFILE" 2>&1
fi

# Build Image
echo "=== Compiling Kernel Image ===" >> "$LOGFILE"
make -j3 O="$OUTDIR" ARCH=arm64 HOSTCC=clang HOSTCXX=clang++ CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 Image >> "$LOGFILE" 2>&1

if [ ! -f "$OUTDIR/arch/arm64/boot/Image" ]; then
    echo "ERROR: Kernel Image not found!" >> "$LOGFILE"
    echo "ERROR" > "$STATUSFILE"
    exit 1
fi

echo "=== Kernel Image Compiled Successfully! ===" >> "$LOGFILE"

# Build Modules
echo "=== Building Kernel Modules ===" >> "$LOGFILE"
make -j3 O="$OUTDIR" ARCH=arm64 HOSTCC=clang HOSTCXX=clang++ CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 modules >> "$LOGFILE" 2>&1 || true

# Prepare AnyKernel3
echo "=== Packaging AnyKernel3 Flashable Zip ===" >> "$LOGFILE"
cp "$OUTDIR/arch/arm64/boot/Image" AnyKernel3/Image
cd AnyKernel3
ZIP_NAME="VSTHunterKernel-A51-NetHunter-VST-Alpha2.zip"
zip -r9 "$OUTDIR/$ZIP_NAME" * -x "*.zip"
cd "$TOPDIR"

# Copy to SDCARD and FINAL_VST_RELEASE
mkdir -p "$TOPDIR/FINAL_RELEASE_ALPHA2" "/run/media/valentin_stars/linux/FINAL_VST_RELEASE"
cp "$OUTDIR/$ZIP_NAME" "$TOPDIR/FINAL_RELEASE_ALPHA2/" || true
cp "$OUTDIR/$ZIP_NAME" "/run/media/valentin_stars/linux/FINAL_VST_RELEASE/" || true

if [ -d "$SDCARD" ]; then
    cp "$OUTDIR/$ZIP_NAME" "$SDCARD/" || true
    echo "=== Copied $ZIP_NAME to $SDCARD ===" >> "$LOGFILE"
fi

echo "SUCCESS" > "$STATUSFILE"
echo "=== ALL DONE: $(date) ===" >> "$LOGFILE"
