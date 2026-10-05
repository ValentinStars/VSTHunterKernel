# This fragment is inserted into the inspected Chroot Manager before dispatch.
# Normalize the kalifs symlink so status matches actual mount table paths.
if [ -n "$MNT" ] && [ -d "$MNT" ]; then
    MNT=$(readlink -f "$MNT")
fi
if [ "${1:-}" = backup ]; then
    shift
    [ "$#" = 2 ] || { echo 'Usage: backup ROOT /path/archive.tar.gz' >&2; exit 64; }
    exec /data/adb/modules/vst-nethunter-sd-fix/backup-rootfs.sh "$1" "$2"
fi
case "${1:-}" in
    remove|restore)
        echo 'This Kali uses an SD image. Stop it and manage the image explicitly; directory removal/restore is unsupported.' >&2
        exit 64 ;;
esac
