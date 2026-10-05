#!/system/bin/sh
# Preserve command arguments and replace the launcher with the chroot process.
set -eu
vst_name=${0##*/}
case "$vst_name" in
    andrax|andrax-ng) vst_root=/data/data/org.snakesecurity.andrax/tmpsystem ;;
    stryker|strykeross) vst_root=/data/local/stryker/release ;;
    *) vst_root=/data/local/nhsystem/kali-arm64 ;;
esac
vst_quote() {
    printf "'"
    printf '%s' "$1" | sed "s/'/'\\\\''/g"
    printf "'"
}
vst_pty_ready=0
if [ "${1:-}" = --vst-internal-pty ] && [ "$(id -u)" = 0 ]; then
    vst_pty_ready=1
    shift
fi
vst_command="exec $(vst_quote "$0")"
for vst_argument do
    vst_command="$vst_command $(vst_quote "$vst_argument")"
done
if [ "$#" -eq 0 ] && [ "$vst_pty_ready" = 0 ]; then
    # Magisk -c can detach from the caller's controlling terminal. Allocate one.
    exec su -i -c "$vst_command --vst-internal-pty"
fi
if [ "$(id -u)" != 0 ]; then
    exec su -c "$vst_command"
fi
if [ ! -f "$vst_root/etc/passwd" ]; then
    echo "Chroot is not mounted: $vst_root" >&2
    exit 1
fi
vst_shell=$(awk -F: '$1 == "root" {print $7; exit}' "$vst_root/etc/passwd")
[ -n "$vst_shell" ] || vst_shell=/bin/sh
if [ ! -x "$vst_root$vst_shell" ]; then
    echo "Root shell is missing: $vst_shell" >&2
    exit 1
fi
vst_prepare=/data/adb/modules/vst-nethunter-sd-fix/prepare-chroot.sh
[ -x "$vst_prepare" ] || { echo 'Chroot mount helper is missing' >&2; exit 1; }
"$vst_prepare" "$vst_root"
vst_chroot=/system/bin/chroot
[ -x "$vst_chroot" ] || vst_chroot=/data/adb/magisk/busybox
vst_term=${TERM:-xterm-256color}
if [ "$#" -eq 0 ]; then set -- "$vst_shell" -l; fi
if [ "$vst_chroot" = /data/adb/magisk/busybox ]; then
    set -- chroot "$vst_root" /usr/bin/env -i HOME=/root USER=root LOGNAME=root SHELL="$vst_shell" TERM="$vst_term" PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin "$@"
else
    set -- "$vst_root" /usr/bin/env -i HOME=/root USER=root LOGNAME=root SHELL="$vst_shell" TERM="$vst_term" PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin "$@"
fi
exec "$vst_chroot" "$@"
