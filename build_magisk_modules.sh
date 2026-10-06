#!/usr/bin/env bash
set -euo pipefail

TOPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$TOPDIR/magisk_pack_src"
OUT_DIR="$TOPDIR/magisk_release_zips"
KERNEL_OUT="${VST_OUT_DIR:-$TOPDIR/out_alpha5}"
if [ ! -s "$KERNEL_OUT/drivers/net/can/slcan.ko" ]; then
    echo "Build Alpha5 Image and modules before packaging: $KERNEL_OUT" >&2
    exit 1
fi

rm -rf "$BASE_DIR" "$OUT_DIR"
mkdir -p "$BASE_DIR" "$OUT_DIR"

create_base_module() {
    local mod_dir="$1"
    local id="$2"
    local name="$3"
    local desc="$4"

    mkdir -p "$mod_dir/META-INF/com/google/android" "$mod_dir/system/bin"
    
    cat << MEOF > "$mod_dir/module.prop"
id=$id
name=$name
version=v2.0-Alpha5
versionCode=500
author=Valentin Stars (vstbio.t.me)
description=$desc
MEOF

    cat << 'CEOF' > "$mod_dir/customize.sh"
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755
[ ! -f "$MODPATH/service.sh" ] || set_perm "$MODPATH/service.sh" 0 0 0755
CEOF

}

# --- Module 1: BadUSB & NetHunter HID ---
MOD1="$BASE_DIR/01_VST_BadUSB_NetHunter_Arsenal"
create_base_module "$MOD1" "vst-badusb" "VST BadUSB & NetHunter HID Arsenal" "Unlocks /dev/hidg0 and /dev/hidg1 permissions with CLI BadUSB toolkit for Rucky, Duckyscript and NetHunter Arsenal."
cat << 'SEOF' > "$MOD1/service.sh"
#!/system/bin/sh
chmod 666 /dev/hidg0 2>/dev/null || true
chmod 666 /dev/hidg1 2>/dev/null || true
SEOF
chmod 755 "$MOD1/service.sh"

cat << 'BEOF' > "$MOD1/system/bin/vst-badusb"
#!/system/bin/sh
echo "=== VST BadUSB & NetHunter HID Arsenal (hakirfon) by Valentin Stars ==="
if [ -c /dev/hidg0 ]; then
    echo "[+] Keyboard gadget node: /dev/hidg0 (present)"
else
    echo "[-] /dev/hidg0 not found"
fi
if [ -c /dev/hidg1 ]; then
    echo "[+] Mouse gadget node: /dev/hidg1 (present)"
else
    echo "[-] /dev/hidg1 not found"
fi
echo "Permissions:"
ls -l /dev/hidg* 2>/dev/null
BEOF
chmod 755 "$MOD1/system/bin/vst-badusb"

# --- Module 2: WireGuard Toolkit ---
MOD2="$BASE_DIR/02_VST_WireGuard_Toolkit"
create_base_module "$MOD2" "vst-wireguard" "VST WireGuard Kernel Toolkit" "Reports WireGuard kernel support and active interfaces."
cat << 'SEOF' > "$MOD2/service.sh"
#!/system/bin/sh
# Routing and congestion control are configured by the VPN/network manager.
SEOF
chmod 755 "$MOD2/service.sh"

cat << 'BEOF' > "$MOD2/system/bin/vst-wg"
#!/system/bin/sh
echo "=== VST WireGuard Kernel Toolkit by Valentin Stars ==="
if [ -d /sys/module/wireguard ]; then
    echo "[+] WireGuard Kernel Module: present"
    cat /sys/module/wireguard/version 2>/dev/null || true
else
    echo "[-] WireGuard module not found in /sys/module/"
fi
echo "Active WireGuard interfaces:"
ip link show type wireguard 2>/dev/null || ip link | grep wg
BEOF
chmod 755 "$MOD2/system/bin/vst-wg"

# --- Module 3: Wireless Pentest Arsenal ---
MOD3="$BASE_DIR/03_VST_Wireless_Pentest_Arsenal"
create_base_module "$MOD3" "vst-wireless" "VST Wireless Pentest Firmware & Toolkit" "Installs the embedded firmware set and provides an iw-based mode helper. Driver support depends on the kernel configuration."
mkdir -p "$MOD3/system/etc/firmware"
while read -r vst_hash vst_name; do
    mkdir -p "$MOD3/system/etc/firmware/$(dirname "$vst_name")"
    cp "$TOPDIR/firmware/$vst_name" "$MOD3/system/etc/firmware/$vst_name"
done < "$TOPDIR/firmware/alpha5-firmware.sha256"
cp "$TOPDIR/firmware/"LICENCE.* "$MOD3/system/etc/firmware/"

cat << 'BEOF' > "$MOD3/system/bin/vst-wifi"
#!/system/bin/sh
set -eu
vst_iface=${2:-wlan1}
case "${1:-list}" in
    list) ip link show; exit 0 ;;
    monitor|start) vst_type=monitor ;;
    managed|stop) vst_type=managed ;;
    power|txpower)
        vst_power=${3:?Specify tx power in dBm}
        case "$vst_power" in *[!0-9]*|'') echo 'TX power must be a nonnegative integer' >&2; exit 64 ;; esac
        iw dev "$vst_iface" set txpower fixed "$((vst_power * 100))"
        iw dev "$vst_iface" info
        exit 0 ;;
    *) echo 'Usage: vst-wifi [monitor|managed|txpower|list] [interface] [dBm]' >&2; exit 64 ;;
esac
ip link show dev "$vst_iface" >/dev/null
command -v iw >/dev/null || { echo 'iw is required' >&2; exit 1; }
ip link set "$vst_iface" down
if ! iw dev "$vst_iface" set type "$vst_type"; then
    ip link set "$vst_iface" up
    exit 1
fi
ip link set "$vst_iface" up
iw dev "$vst_iface" info
BEOF
chmod 755 "$MOD3/system/bin/vst-wifi"

# --- Module 4: SDR Radio Hacker ---
MOD4="$BASE_DIR/04_VST_SDR_Radio_Hacker"
create_base_module "$MOD4" "vst-sdr" "VST SDR & Radio Hacker Toolkit" "SDR device permissions and rules for HackRF One, RTL-SDR, AirSpy, MSI2500 with 'vst-sdr' helper."
cat << 'SEOF' > "$MOD4/service.sh"
#!/system/bin/sh
# Preserve Android USB node and directory permissions; SDR tools use root.
SEOF
chmod 755 "$MOD4/service.sh"

cat << 'BEOF' > "$MOD4/system/bin/vst-sdr"
#!/system/bin/sh
echo "=== VST SDR & Radio Hacker Toolkit (hakirfon) by Valentin Stars ==="
echo "[*] Checking connected USB SDR devices..."
lsusb 2>/dev/null || echo "lsusb tool not in PATH"
echo "USB Device nodes:"
ls -la /dev/bus/usb/*/* 2>/dev/null | head -n 10
BEOF
chmod 755 "$MOD4/system/bin/vst-sdr"

# --- Module 5: Hardware Hacking & SocketCAN ---
MOD5="$BASE_DIR/05_VST_Hardware_Hacking_CAN"
create_base_module "$MOD5" "vst-hardware-can" "VST Hardware Hacking & SocketCAN Pack" "Auto-configures CDC-ACM for Flipper Zero, Proxmark3, Chameleon, FTDI, CP210x and SocketCAN with 'vst-can' helper."
mkdir -p "$MOD5/system/lib/modules"
cp "$KERNEL_OUT/drivers/net/can/slcan.ko" "$MOD5/system/lib/modules/slcan.ko"

cat << 'SEOF' > "$MOD5/service.sh"
#!/system/bin/sh
MODDIR=${0%/*}
chmod 666 /dev/ttyACM* /dev/ttyUSB* 2>/dev/null || true
if [ -f "$MODDIR/system/lib/modules/slcan.ko" ]; then
    if ! grep -q '^slcan ' /proc/modules; then
        insmod "$MODDIR/system/lib/modules/slcan.ko" || exit 1
    fi
fi
SEOF
chmod 755 "$MOD5/service.sh"

cat << 'BEOF' > "$MOD5/system/bin/vst-can"
#!/system/bin/sh
echo "=== VST Hardware Hacking & SocketCAN (hakirfon) by Valentin Stars ==="
echo "Connected CDC ACM / Serial devices:"
ls -l /dev/ttyACM* /dev/ttyUSB* 2>/dev/null || echo "No serial devices currently connected"
echo "CAN network interfaces:"
ip link show type can 2>/dev/null || ip link | grep can
BEOF
chmod 755 "$MOD5/system/bin/vst-can"

# --- Module 6: hakirfon Edition Branding ---
MOD6="$BASE_DIR/06_VST_hakirfon_Edition_SystemProp"
create_base_module "$MOD6" "vst-hakirfon-branding" "VST hakirfon Edition" "Sets the displayed hakirfon Alpha5 build name."
cat << 'PEOF' > "$MOD6/system.prop"
ro.build.display.id=hakirfon Alpha5 - Valentin Stars
PEOF

# --- Module 7: USB OTG Power Switcher ---
MOD7="$BASE_DIR/07_VST_USB_OTG_Power_Switcher"
create_base_module "$MOD7" "vst-otg-power" "VST USB OTG status" "Reports USB OTG state; this hardware interface does not select an output current."
cat << 'BEOF' > "$MOD7/system/bin/vst-otg"
#!/system/bin/sh
case "${1:-status}" in
    status)
        for node in /sys/class/power_supply/otg/online /sys/class/sec/switch/attached_dev; do
            [ ! -r "$node" ] || { printf '%s: ' "$node"; cat "$node"; }
        done
        ;;
    *)
        echo 'The A51 exposed controls do not select 900/1500/2000 mA OTG output.' >&2
        echo 'Usage: vst-otg status' >&2
        exit 2
        ;;
esac
BEOF
chmod 755 "$MOD7/system/bin/vst-otg"

# Native SD image and terminal sessions.
MOD0="$BASE_DIR/00_VST_NetHunter_MicroSD_Fix"
create_base_module "$MOD0" "vst-nethunter-sd-fix" "VST NetHunter SD and terminal fixes" "Serialized native SD mount, configured login shells, correct PTYs and safe unmount."
sed -i 's/^version=.*/version=v2.0-Alpha5.1-terminal2/; s/^versionCode=.*/versionCode=5012/' "$MOD0/module.prop"
cp "$TOPDIR/tools/alpha5/sd-mount.sh" "$MOD0/service.sh"
cp "$TOPDIR/tools/alpha5/prepare-chroot.sh" "$MOD0/prepare-chroot.sh"
cp "$TOPDIR/tools/alpha5/bootkali_init.sh" "$MOD0/bootkali_init.sh"
cp "$TOPDIR/tools/alpha5/manager-dispatch.sh" "$MOD0/manager-dispatch.sh"
cp "$TOPDIR/tools/alpha5/backup-rootfs.sh" "$MOD0/backup-rootfs.sh"
cp "$TOPDIR/tools/alpha5/sd-customize.sh" "$MOD0/customize.sh"
cp "$TOPDIR/tools/alpha5/killkali.sh" "$MOD0/system/bin/killkali"
for alias in nh nethunter kali bootkali vst xakirphone andrax andrax-ng stryker strykeross pentest hack; do
    cp "$TOPDIR/tools/alpha5/nh.sh" "$MOD0/system/bin/$alias"
done
chmod 755 "$MOD0/service.sh" "$MOD0/prepare-chroot.sh" "$MOD0/backup-rootfs.sh" "$MOD0/system/bin/"*

MOD8="$BASE_DIR/08_VST_Alpha5_Runtime"
create_base_module "$MOD8" "vst-alpha5-runtime" "VST Alpha5 runtime fixes" "Sets hostname VST and disables incompatible Wi-Fi link layer statistics."
cp "$TOPDIR/tools/alpha5/runtime-service.sh" "$MOD8/service.sh"
chmod 755 "$MOD8/service.sh"

# --- Package All Modules into ZIPs ---
for mod in "$BASE_DIR"/*; do
    if [ -d "$mod" ]; then
        mod_name="$(basename "$mod")"
        cd "$mod"
        zip -r9 "$OUT_DIR/${mod_name}.zip" *
        echo "[+] Packaged $OUT_DIR/${mod_name}.zip"
    fi
done

echo "============================================================"
echo "[+] All Magisk Modules Packaged Successfully into $OUT_DIR"
echo "============================================================"
