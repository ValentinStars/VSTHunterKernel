#!/system/bin/sh
SCRIPT_PATH=$(readlink -f "$0")
. "${SCRIPT_PATH%/*}/bootkali_env" || exit 1
if [ -e /data/adb/vst-kali-maintenance ]; then
    echo 'Kali image is offline for filesystem maintenance' >&2
    exit 1
fi
[ -n "$MNT" ] && [ -f "$MNT/etc/passwd" ] || exit 1
/data/adb/modules/vst-nethunter-sd-fix/prepare-chroot.sh "$MNT" || exit 1
