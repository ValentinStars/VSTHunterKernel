#!/system/bin/sh
# Export an image-backed Kali rootfs without archiving Android's bind mounts.
set -eu
set -o pipefail
vst_root=$(readlink -f "${1:?Specify the Kali root directory}")
vst_output=${2:?Specify an absolute archive path}
[ "$vst_root" = /data/local/nhsystem/kali-arm64 ] || { echo 'Unsupported chroot for this image export' >&2; exit 64; }
case "$vst_output" in /*) ;; *) echo 'Archive path must be absolute' >&2; exit 64 ;; esac
case "$vst_output" in *.tar.gz) vst_compress=gzip ;; *.tar.xz) vst_compress=xz ;; *) echo 'Use .tar.gz or .tar.xz' >&2; exit 64 ;; esac
vst_parent=$(readlink -f "${vst_output%/*}")
[ -d "$vst_parent" ] || exit 1
case "$vst_parent" in "$vst_root"|"$vst_root"/*) echo 'Save the archive outside Kali' >&2; exit 64 ;; esac
vst_output="$vst_parent/${vst_output##*/}"
[ ! -e "$vst_output" ] || { echo 'Archive already exists; choose another name' >&2; exit 1; }
[ -f "$vst_root/etc/passwd" ] || { echo 'Start Kali before exporting its rootfs' >&2; exit 1; }
mkdir -p /data/adb/vst-locks
if [ "${3:-}" != --image-locked ]; then
    exec /data/adb/magisk/busybox flock /data/adb/vst-locks/kali-image.lock /system/bin/sh "$0" "$vst_root" "$vst_output" --image-locked
fi
if [ "${4:-}" != --prepared ]; then
    exec /data/adb/magisk/busybox flock /data/adb/vst-locks/prepare_data_local_nhsystem_kali-arm64.lock /system/bin/sh "$0" "$vst_root" "$vst_output" --image-locked --prepared
fi
[ -f "$vst_root/etc/passwd" ] || { echo "Kali was unmounted before export" >&2; exit 1; }
for vst_entry in /proc/[0-9]*/root; do
    vst_path=$(readlink "$vst_entry" 2>/dev/null || true)
    case "$vst_path" in "$vst_root"|"$vst_root"/*)
        echo 'Stop Kali services and close its terminal sessions before exporting' >&2
        exit 1 ;;
    esac
done
umask 077
vst_temp=$(mktemp "$vst_output.part.XXXXXX")
trap 'rm -f "$vst_temp"' EXIT
set --
# Exclude every nested mount, including Android storage and device/proc trees.
for vst_mount in $(awk -v root="$vst_root/" 'index($2,root) == 1 {print $2}' /proc/mounts); do
    set -- "$@" "--exclude=kali-arm64/${vst_mount#"$vst_root/"}"
done
case "$vst_compress" in
    gzip) /data/adb/magisk/busybox tar -czf "$vst_temp" "$@" -C /data/local/nhsystem kali-arm64 ;;
    xz)
        [ -x "$vst_root/usr/bin/xz" ] || { echo 'Kali xz is unavailable; use .tar.gz' >&2; exit 1; }
        /data/adb/magisk/busybox tar -cf - "$@" -C /data/local/nhsystem kali-arm64 |
            /system/bin/chroot "$vst_root" /usr/bin/xz -T1 -c > "$vst_temp"
        ;;
esac
sync
mv "$vst_temp" "$vst_output"
printf 'Rootfs archive created: %s\n' "$vst_output"
