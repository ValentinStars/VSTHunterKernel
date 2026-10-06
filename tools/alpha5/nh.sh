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
if [ "$vst_pty_ready" = 0 ] && { [ "$#" -eq 0 ] || { [ -t 0 ] && [ -t 1 ]; }; }; then
    # Include explicitly selected interactive programs, such as nh pwsh.
    # The internal marker precedes arguments so it is consumed exactly once.
    vst_pty_command="exec $(vst_quote "$0") --vst-internal-pty"
    for vst_argument do
        vst_pty_command="$vst_pty_command $(vst_quote "$vst_argument")"
    done
    exec su -i -c "$vst_pty_command"
fi
if [ "$(id -u)" != 0 ]; then
    exec su -c "$vst_command"
fi
if [ "$vst_root" = /data/local/nhsystem/kali-arm64 ] && [ -e /data/adb/vst-kali-maintenance ]; then
    echo 'Kali image is offline for filesystem maintenance' >&2
    exit 1
fi
if [ "$vst_root" = /data/local/nhsystem/kali-arm64 ] && [ ! -f "$vst_root/etc/passwd" ]; then
    /system/bin/sh /data/adb/modules/vst-nethunter-sd-fix/service.sh || exit 1
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
# The laptop may pass a terminal absent from the chroot's terminfo database.
# Keep supported types; use a known color terminal when lookup fails.
if [ -x "$vst_root/usr/bin/infocmp" ]; then
    if ! /system/bin/chroot "$vst_root" /usr/bin/infocmp "$vst_term" >/dev/null 2>&1; then
        if /system/bin/chroot "$vst_root" /usr/bin/infocmp xterm-256color >/dev/null 2>&1; then
            vst_term=xterm-256color
        else
            vst_term=dumb
        fi
    fi
fi
if [ "$#" -eq 0 ]; then set -- "$vst_shell" -l; fi
if [ "$vst_chroot" = /data/adb/magisk/busybox ]; then
    set -- chroot "$vst_root" /usr/bin/env -i HOME=/root USER=root LOGNAME=root SHELL="$vst_shell" TERM="$vst_term" PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin "$@"
else
    set -- "$vst_root" /usr/bin/env -i HOME=/root USER=root LOGNAME=root SHELL="$vst_shell" TERM="$vst_term" PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin "$@"
fi
exec "$vst_chroot" "$@"
