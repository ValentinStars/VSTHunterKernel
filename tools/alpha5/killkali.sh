#!/system/bin/sh
set -eu
vst_root=/data/local/nhsystem/kali-arm64
mkdir -p /data/adb/vst-locks
if [ "${1:-}" != --locked ]; then
    exec /data/adb/magisk/busybox flock /data/adb/vst-locks/kali-image.lock /system/bin/sh "$0" --locked
fi
if [ "${2:-}" != --prepared ]; then
    exec /data/adb/magisk/busybox flock /data/adb/vst-locks/prepare_data_local_nhsystem_kali-arm64.lock /system/bin/sh "$0" --locked --prepared
fi
vst_busy=0
for vst_entry in /proc/[0-9]*/root; do
    vst_path=$(readlink "$vst_entry" 2>/dev/null || true)
    case "$vst_path" in
        "$vst_root"|"$vst_root/"*)
            vst_pid=${vst_entry#/proc/}; vst_pid=${vst_pid%/root}
            printf 'Kali is busy: PID %s\n' "$vst_pid" >&2
            vst_busy=1 ;;
    esac
done
[ "$vst_busy" = 0 ] || exit 1
sync
vst_mounts=$(awk -v root="$vst_root" '$2 == root || index($2,root"/") == 1 {print $2}' /proc/mounts | sort -r)
for vst_target in $vst_mounts; do
    umount "$vst_target" || exit 1
done
printf '%s\n' 'Kali unmounted cleanly'
