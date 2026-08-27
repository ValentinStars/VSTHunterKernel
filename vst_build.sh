#!/usr/bin/env bash
# ==============================================================================
#  ⚡ VSTHunterKernel (VSTnh) Universal Build System ⚡
#  Author: Valentin Stars (vstbio.t.me)
#  Standard: #STOP_SHITCODING
# ==============================================================================

set -eo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TOPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLCHAIN="$TOPDIR/Neutron_Clang_18/bin"
export PATH="$TOOLCHAIN:$PATH"

OUTDIR="$TOPDIR/out_alpha3"
RELEASE_DIR="/run/media/valentin_stars/linux/FINAL_VST_RELEASE"
LOGFILE="/run/media/valentin_stars/linux/build.log"
DEFCONFIG="vstnh_defconfig"
JOBS="$(nproc 2>/dev/null || echo 4)"

VERSION="Alpha3.1"
DO_CLEAN=false
DO_MODULES=false
DO_RELEASE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -c|--clean)
            DO_CLEAN=true
            shift
            ;;
        -m|--modules)
            DO_MODULES=true
            shift
            ;;
        -r|--release)
            DO_RELEASE=true
            shift
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -h|--help)
            echo -e "${BOLD}Usage:${NC} $0 [OPTIONS]"
            echo -e "  -v, --version <TAG>   Set kernel release version (default: Alpha3.1)"
            echo -e "  -c, --clean           Perform clean build (wipe out directory)"
            echo -e "  -m, --modules         Build and package all Magisk modules (00-07)"
            echo -e "  -r, --release         Upload build to GitHub Release via gh CLI"
            echo -e "  -j, --jobs <N>        Compilation threads count (default: $(nproc))"
            echo -e "  -h, --help            Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Unknown argument: $1${NC}"
            exit 1
            ;;
    esac
done

ZIP_NAME="VSTHunterKernel-A51-NetHunter-VST-${VERSION}.zip"

echo -e "${CYAN}======================================================================${NC}"
echo -e "${BOLD}${GREEN}        ⚡ VSTHunterKernel (VSTnh) Build System ⚡${NC}"
echo -e "  ${YELLOW}Target:${NC} Samsung Galaxy A51 (SM-A515F / universal9611)"
echo -e "  ${YELLOW}Version:${NC} ${BOLD}${VERSION}${NC}"
echo -e "  ${YELLOW}Toolchain:${NC} Neutron Clang 18 (LLVM / LLD)"
echo -e "  ${YELLOW}Output Zip:${NC} ${ZIP_NAME}"
echo -e "  ${YELLOW}Release Dir:${NC} ${RELEASE_DIR}"
echo -e "${CYAN}======================================================================${NC}"

# Clean if requested
if [ "$DO_CLEAN" = true ]; then
    echo -e "${YELLOW}[*] Performing clean build (removing $OUTDIR)...${NC}"
    rm -rf "$OUTDIR"/*
fi

mkdir -p "$OUTDIR" "$RELEASE_DIR"
echo "=== VSTHunterKernel Build Started: $(date) | Version: $VERSION ===" > "$LOGFILE"

# 1. Update defconfig with version
echo -e "${BLUE}[1/5] Configuring kernel (${DEFCONFIG}) with LOCALVERSION=-NetHunter-VST-${VERSION}...${NC}"
sed -i "s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"-NetHunter-VST-${VERSION}\"/" "$TOPDIR/arch/arm64/configs/$DEFCONFIG"

# Build defconfig
make O="$OUTDIR" ARCH=arm64 \
    HOSTCC=clang HOSTCXX=clang++ CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm \
    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    LLVM=1 LLVM_IAS=1 "$DEFCONFIG" >> "$LOGFILE" 2>&1

make O="$OUTDIR" ARCH=arm64 \
    HOSTCC=clang HOSTCXX=clang++ CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm \
    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    LLVM=1 LLVM_IAS=1 olddefconfig >> "$LOGFILE" 2>&1

# 2. Compile Kernel Image
echo -e "${BLUE}[2/5] Compiling Kernel Image (-j${JOBS})...${NC}"
make -j"$JOBS" O="$OUTDIR" ARCH=arm64 \
    HOSTCC=clang HOSTCXX=clang++ CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm \
    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    LLVM=1 LLVM_IAS=1 Image >> "$LOGFILE" 2>&1

if [ ! -f "$OUTDIR/arch/arm64/boot/Image" ]; then
    echo -e "${RED}[❌] ERROR: Kernel Image compilation failed! Check $LOGFILE${NC}"
    exit 1
fi
echo -e "${GREEN}[✔] Kernel Image compiled successfully! (${OUTDIR}/arch/arm64/boot/Image)${NC}"

# 3. Build Kernel Modules (e.g. slcan.ko)
echo -e "${BLUE}[3/5] Building Kernel Modules...${NC}"
make -j"$JOBS" O="$OUTDIR" ARCH=arm64 \
    HOSTCC=clang HOSTCXX=clang++ CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm \
    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    LLVM=1 LLVM_IAS=1 modules >> "$LOGFILE" 2>&1 || true

# 4. Packaging AnyKernel3 Zip
echo -e "${BLUE}[4/5] Packaging AnyKernel3 Flashable Zip (${ZIP_NAME})...${NC}"
cp "$OUTDIR/arch/arm64/boot/Image" "$TOPDIR/AnyKernel3/Image"

# Update AnyKernel3 metadata
sed -i "s/kernel.string=VSTHunterKernel (VSTnh) .*/kernel.string=VSTHunterKernel (VSTnh) ${VERSION} by Valentin Stars/" "$TOPDIR/AnyKernel3/anykernel.sh"
cat << VEOF > "$TOPDIR/AnyKernel3/version"
Kernel: VSTHunterKernel (VSTnh) ${VERSION}
Device: Samsung Galaxy A51 (SM-A515F / universal9611)
OS: Android 13-16 (Evolution X / AOSP)
Branding: hakirfon
Author: Valentin Stars (vstbio.t.me)
VEOF

cd "$TOPDIR/AnyKernel3"
zip -r9 "$RELEASE_DIR/$ZIP_NAME" * -x "*.zip" >> "$LOGFILE" 2>&1
cp "$RELEASE_DIR/$ZIP_NAME" "$OUTDIR/$ZIP_NAME" || true
cd "$TOPDIR"

echo -e "${GREEN}[✔] Zip packaged: ${RELEASE_DIR}/${ZIP_NAME}${NC}"

# 5. Build Magisk Modules if requested
if [ "$DO_MODULES" = true ]; then
    echo -e "${BLUE}[5/5] Packaging Magisk Modules pack (00-07)...${NC}"
    if [ -f "$TOPDIR/build_magisk_modules.sh" ]; then
        "$TOPDIR/build_magisk_modules.sh" >> "$LOGFILE" 2>&1
        cp "$TOPDIR"/magisk_release_zips/*.zip "$RELEASE_DIR/" || true
        echo -e "${GREEN}[✔] Magisk modules updated in ${RELEASE_DIR}${NC}"
    fi
fi

# GitHub Release upload if requested
if [ "$DO_RELEASE" = true ]; then
    TAG="v2.0-${VERSION}"
    echo -e "${YELLOW}[*] Uploading release ${TAG} to GitHub...${NC}"
    gh release upload "$TAG" "$RELEASE_DIR/$ZIP_NAME" --clobber -R ValentinStars/VSTHunterKernel || \
    gh release create "$TAG" "$RELEASE_DIR/$ZIP_NAME" --title "VSTHunterKernel ${TAG}" --notes "Release ${TAG} by Valentin Stars" -R ValentinStars/VSTHunterKernel || true
fi

echo -e "${GREEN}======================================================================${NC}"
echo -e "${BOLD}${GREEN}  🎉 VSTHunterKernel ${VERSION} BUILD FINISHED SUCCESSFULLY! 🎉${NC}"
echo -e "  Flashable Zip: ${BOLD}${RELEASE_DIR}/${ZIP_NAME}${NC}"
echo -e "${GREEN}======================================================================${NC}"
