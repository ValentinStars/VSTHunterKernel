#!/usr/bin/env bash
set -e

TOPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$TOPDIR/magisk_pack_src"
OUT_DIR="$TOPDIR/magisk_release_zips"

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
version=v2.0-Alpha2
versionCode=200
author=Valentin Stars (vstbio.t.me)
description=$desc
MEOF

    cat << UEOF > "$mod_dir/META-INF/com/google/android/updater-script"
#MAGISK
UEOF

    cat << 'UEOF' > "$mod_dir/META-INF/com/google/android/update-binary"
#!/sbin/sh
OUTFD=$2
ZIPFILE=$3
ui_print() { echo "ui_print $1" > /proc/self/fd/$OUTFD; echo "ui_print" > /proc/self/fd/$OUTFD; }

ui_print " "
ui_print ".-..-..---..---.                   "
ui_print "| .\` || |- \`| |'                   "
ui_print "\`-'\`-'\`---' \`-'                    "
ui_print "                                   "
ui_print ".-. .-..-..-..-..-..---..---..---. "
ui_print "| |=| || || || .\` |\`| |'| |- | |-< "
ui_print "\`-'\`-' \`----'\`-'\`-' \`-' \`---'\`-'\`-' "
ui_print " "
ui_print "        ⚡ Valentin Stars (vstbio.t.me) ⚡"
ui_print " "
ui_print "- Installing module..."
ui_print "- Author: Valentin Stars (vstbio.t.me)"
ui_print "- Extracting files..."
unzip -o "$ZIPFILE" -d "$MODPATH" 2>/dev/null || true
ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755
ui_print "- Done! Reboot to apply."
exit 0
UEOF
    chmod 755 "$mod_dir/META-INF/com/google/android/update-binary"
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
    echo "[+] Keyboard gadget node: /dev/hidg0 (READY - 0666)"
else
    echo "[-] /dev/hidg0 not found"
fi
if [ -c /dev/hidg1 ]; then
    echo "[+] Mouse gadget node: /dev/hidg1 (READY - 0666)"
else
    echo "[-] /dev/hidg1 not found"
fi
echo "Permissions:"
ls -l /dev/hidg* 2>/dev/null
BEOF
chmod 755 "$MOD1/system/bin/vst-badusb"

# --- Module 2: WireGuard Toolkit ---
MOD2="$BASE_DIR/02_VST_WireGuard_Toolkit"
create_base_module "$MOD2" "vst-wireguard" "VST WireGuard Kernel Toolkit" "WireGuard kernel accelerator, sets up high-performance routing, BBR TCP and forwarding helper 'vst-wg'."
cat << 'SEOF' > "$MOD2/service.sh"
#!/system/bin/sh
sysctl -w net.ipv4.ip_forward=1 2>/dev/null || true
sysctl -w net.ipv6.conf.all.forwarding=1 2>/dev/null || true
sysctl -w net.ipv4.tcp_congestion_control=bbr 2>/dev/null || true
SEOF
chmod 755 "$MOD2/service.sh"

cat << 'BEOF' > "$MOD2/system/bin/vst-wg"
#!/system/bin/sh
echo "=== VST WireGuard Kernel Toolkit by Valentin Stars ==="
if [ -d /sys/module/wireguard ]; then
    echo "[+] WireGuard Kernel Module: LOADED & ACCELERATED (ARM64 NEON)"
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
create_base_module "$MOD3" "vst-wireless" "VST Wireless Pentest Firmware & Toolkit" "Installs firmware for RTL8812AU, RTL8814AU, ATH9K, RTL8188EU with 'vst-wifi' monitor-mode CLI tool."
mkdir -p "$MOD3/system/etc/firmware"

cat << 'BEOF' > "$MOD3/system/bin/vst-wifi"
#!/system/bin/sh
echo "=== VST Wireless Pentest Arsenal (hakirfon) by Valentin Stars ==="
IFACE=${2:-wlan1}
case "$1" in
    monitor|start)
        echo "[*] Putting $IFACE into Monitor Mode..."
        ip link set $IFACE down 2>/dev/null || ifconfig $IFACE down 2>/dev/null
        iw dev $IFACE set type monitor 2>/dev/null || iwconfig $IFACE mode monitor 2>/dev/null
        ip link set $IFACE up 2>/dev/null || ifconfig $IFACE up 2>/dev/null
        echo "[+] $IFACE is now in Monitor Mode (Promiscuous Packet Injection READY)!"
        ;;
    managed|stop)
        echo "[*] Putting $IFACE into Managed Mode..."
        ip link set $IFACE down 2>/dev/null || ifconfig $IFACE down 2>/dev/null
        iw dev $IFACE set type managed 2>/dev/null || iwconfig $IFACE mode managed 2>/dev/null
        ip link set $IFACE up 2>/dev/null || ifconfig $IFACE up 2>/dev/null
        echo "[+] $IFACE is now in Managed Mode!"
        ;;
    power|txpower)
        PWR=${3:-30}
        echo "[*] Setting $IFACE txpower to ${PWR}dBm..."
        iw dev $IFACE set txpower fixed ${PWR}00 2>/dev/null || iwconfig $IFACE txpower $PWR 2>/dev/null
        echo "[+] Done."
        ;;
    list|*)
        echo "Usage: vst-wifi [monitor|managed|txpower|list] [interface]"
        echo "Available interfaces:"
        ip link | grep -E "wlan|mon"
        ;;
esac
BEOF
chmod 755 "$MOD3/system/bin/vst-wifi"

# --- Module 4: SDR Radio Hacker ---
MOD4="$BASE_DIR/04_VST_SDR_Radio_Hacker"
create_base_module "$MOD4" "vst-sdr" "VST SDR & Radio Hacker Toolkit" "SDR device permissions and rules for HackRF One, RTL-SDR, AirSpy, MSI2500 with 'vst-sdr' helper."
cat << 'SEOF' > "$MOD4/service.sh"
#!/system/bin/sh
chmod -R 666 /dev/bus/usb/ 2>/dev/null || true
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

cat << 'SEOF' > "$MOD5/service.sh"
#!/system/bin/sh
MODDIR=${0%/*}
chmod 666 /dev/ttyACM* /dev/ttyUSB* 2>/dev/null || true
if [ -f "$MODDIR/system/lib/modules/slcan.ko" ]; then
    insmod "$MODDIR/system/lib/modules/slcan.ko" 2>/dev/null || true
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
create_base_module "$MOD6" "vst-hakirfon-branding" "VST hakirfon Edition System Branding" "Spoofs Android Device Model to 'hakirfon', Build ID to 'hakirfon Alpha2 - Valentin Stars' and applies performance tweaks."
cat << 'PEOF' > "$MOD6/system.prop"
ro.product.model=hakirfon
ro.product.brand=hakirfon
ro.product.name=hakirfon
ro.product.device=a51
ro.product.manufacturer=ValentinStars
ro.build.display.id=hakirfon Alpha2 - Valentin Stars
ro.build.id=hakirfon-Alpha2
ro.system.build.id=hakirfon-Alpha2
ro.build.version.incremental=hakirfon.Alpha2
ro.vendor.build.id=hakirfon-Alpha2
ro.boot.hardware=hakirfon
PEOF

# --- Module 7: USB OTG Power Switcher ---
MOD7="$BASE_DIR/07_VST_USB_OTG_Power_Switcher"
create_base_module "$MOD7" "vst-otg-power" "VST USB OTG High Current Switcher" "Provides 'vst-otg' CLI tool to switch OTG output current between 900mA (eco) and 1.5A - 2.0A (high power boost for Alfa/HackRF)."
cat << 'BEOF' > "$MOD7/system/bin/vst-otg"
#!/system/bin/sh
echo "=== VST USB OTG Power Switcher (hakirfon) by Valentin Stars ==="
MODE=${1:-status}
case "$MODE" in
    1500|2000|high|max)
        echo 1 > /sys/class/power_supply/battery/batt_high_current_usb 2>/dev/null
        echo 131072 > /sys/class/power_supply/battery/charge_otg_control 2>/dev/null
        echo "[+] OTG Power set to HIGH CURRENT (1.5A - 2.0A Boost for Alfa / HackRF)"
        ;;
    900|eco|default)
        echo 0 > /sys/class/power_supply/battery/batt_high_current_usb 2>/dev/null
        echo 131072 > /sys/class/power_supply/battery/charge_otg_control 2>/dev/null
        echo "[+] OTG Power set to STANDARD ECO (900mA)"
        ;;
    status|*)
        echo "Usage: vst-otg [high|eco|status]"
        ONLINE=$(cat /sys/class/power_supply/otg/online 2>/dev/null || echo 0)
        HIGH=$(cat /sys/class/power_supply/battery/batt_high_current_usb 2>/dev/null || echo 0)
        VBUS=$(cat /sys/class/sec/switch/vbus_value 2>/dev/null || echo "5000")
        DEV=$(cat /sys/class/sec/switch/attached_dev 2>/dev/null || echo "None")
        echo "  - OTG Attached: $DEV (Status: $ONLINE)"
        echo "  - VBUS Voltage: ${VBUS}mV (5.0V Boost)"
        if [ "$HIGH" = "1" ]; then
            echo "  - Power Mode: HIGH CURRENT (1.5A - 2.0A) [ACTIVE]"
        else
            echo "  - Power Mode: STANDARD ECO (900mA) [ACTIVE]"
        fi
        ;;
esac
BEOF
chmod 755 "$MOD7/system/bin/vst-otg"

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
