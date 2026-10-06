#!/system/bin/sh
set -eu
vst_root=${1:?Specify a supported chroot path}
case "$vst_root" in
 /data/local/nhsystem/kali-arm64|/data/local/stryker/release|/data/data/org.snakesecurity.andrax/tmpsystem) ;;
 *) echo 'Unsupported chroot root' >&2; exit 64 ;;
esac
[ -f "$vst_root/etc/passwd" ] || exit 1
vst_key=$(printf '%s' "$vst_root" | tr / _)
mkdir -p /data/adb/vst-locks
chmod 700 /data/adb/vst-locks
if [ "${2:-}" != --locked ]; then
    exec /data/adb/magisk/busybox flock "/data/adb/vst-locks/prepare${vst_key}.lock" /system/bin/sh "$0" "$vst_root" --locked
fi
vst_mounted() {
    awk -v target="$1" '$2 == target {found=1} END {exit !found}' /proc/mounts
}
vst_bind() { /data/adb/magisk/busybox mount -o bind "$1" "$2"; }
mkdir -p "$vst_root/dev" "$vst_root/proc" "$vst_root/sys"
if ! vst_mounted "$vst_root/dev"; then
    mount -t tmpfs -o mode=755,nosuid tmpfs "$vst_root/dev"
fi
# Complete partial setup too. All PTYs use Android's existing devpts instance.
for vst_device in null zero random urandom tty; do
    if ! vst_mounted "$vst_root/dev/$vst_device"; then
        [ -e "$vst_root/dev/$vst_device" ] || touch "$vst_root/dev/$vst_device"
        vst_bind "/dev/$vst_device" "$vst_root/dev/$vst_device"
    fi
done
if [ ! -e "$vst_root/dev/full" ]; then
    mknod -m 666 "$vst_root/dev/full" c 1 7
fi
mkdir -p "$vst_root/dev/net" "$vst_root/dev/bus/usb"
[ -e "$vst_root/dev/net/tun" ] || mknod -m 666 "$vst_root/dev/net/tun" c 10 200
if [ -d /dev/bus/usb ] && ! vst_mounted "$vst_root/dev/bus/usb"; then
    vst_bind /dev/bus/usb "$vst_root/dev/bus/usb"
fi
for vst_fd in fd stdin stdout stderr; do
    case "$vst_fd" in
        fd) vst_target=/proc/self/fd ;;
        stdin) vst_target=/proc/self/fd/0 ;;
        stdout) vst_target=/proc/self/fd/1 ;;
        stderr) vst_target=/proc/self/fd/2 ;;
    esac
    [ -e "$vst_root/dev/$vst_fd" ] || [ -L "$vst_root/dev/$vst_fd" ] || ln -s "$vst_target" "$vst_root/dev/$vst_fd"
done
mkdir -p "$vst_root/dev/pts" "$vst_root/dev/shm"
vst_mounted "$vst_root/dev/pts" || vst_bind /dev/pts "$vst_root/dev/pts"
# A file bind of Android's legacy /dev/ptmx breaks devpts_acquire() on this
# kernel: it looks for pts relative to the file mount. Open the devpts node.
if vst_mounted "$vst_root/dev/ptmx"; then
    umount "$vst_root/dev/ptmx"
fi
if [ "$(readlink "$vst_root/dev/ptmx" 2>/dev/null || true)" != pts/ptmx ]; then
    [ ! -d "$vst_root/dev/ptmx" ] || { echo 'Unexpected ptmx directory' >&2; exit 1; }
    rm -f "$vst_root/dev/ptmx"
    ln -s pts/ptmx "$vst_root/dev/ptmx"
fi
vst_mounted "$vst_root/dev/shm" || mount -t tmpfs -o mode=1777,nosuid,nodev tmpfs "$vst_root/dev/shm"
vst_mounted "$vst_root/proc" || mount -t proc proc "$vst_root/proc"
vst_mounted "$vst_root/sys" || vst_bind /sys "$vst_root/sys"
if [ -d /storage/emulated/0 ] && ! vst_mounted "$vst_root/sdcard"; then
    mkdir -p "$vst_root/sdcard"
    vst_bind /storage/emulated/0 "$vst_root/sdcard"
fi
