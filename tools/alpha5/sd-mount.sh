#!/system/bin/sh
# Mount the Kali image through native external storage. Never fsck a live image.
set -eu
vst_root=/data/local/nhsystem/kali-arm64
[ ! -e /data/adb/vst-kali-maintenance ] || exit 1
mkdir -p /data/adb/vst-locks
chmod 700 /data/adb/vst-locks
if [ "${1:-}" != --locked ]; then
    exec /data/adb/magisk/busybox flock -n /data/adb/vst-locks/kali-image.lock /system/bin/sh "$0" --locked
fi
mounted() { awk -v target="$vst_root" '$2 == target {found=1} END {exit !found}' /proc/mounts; }
prepare_mounts() {
    "${0%/*}/prepare-chroot.sh" "$vst_root"
}
if mounted; then prepare_mounts; exit 0; fi
vst_attempt=0
while [ "$vst_attempt" -lt 120 ]; do
    for vst_image in /mnt/media_rw/*/vst_chroot/kali_arm64.img; do
        [ -f "$vst_image" ] || continue
        # Refuse a second loop attachment to an image already in use.
        for vst_backing in /sys/block/loop*/loop/backing_file; do
            [ -r "$vst_backing" ] || continue
            vst_existing=$(cat "$vst_backing")
            if [ "/${vst_existing#/}" = "$vst_image" ]; then
                echo "Kali image already attached: $vst_backing; inspect its mounts" >&2
                exit 1
            fi
        done
        mkdir -p "$vst_root"
        mount -t ext4 -o loop,rw,noatime "$vst_image" "$vst_root"
        mounted || exit 1
        prepare_mounts
        exit 0
    done
    vst_attempt=$((vst_attempt + 1))
    sleep 2
done
echo 'Kali image not found in native SD storage' >&2
exit 1
