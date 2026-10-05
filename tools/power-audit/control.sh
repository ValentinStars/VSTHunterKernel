#!/system/bin/sh
set -eu
vst_base=/data/adb/vst-power-audit
mkdir -p "$vst_base"
chmod 700 "$vst_base"
case "${1:-status}" in
 start)
    touch "$vst_base/enabled"
    /data/adb/magisk/busybox nohup /system/bin/setsid /system/bin/sh "$vst_base/record.sh" >> "$vst_base/daemon.log" 2>&1 < /dev/null &
    vst_wait=0
    while [ ! -f "$vst_base/pid" ]; do
        vst_wait=$((vst_wait + 1))
        [ "$vst_wait" -le 5 ] || { echo 'No worker started; inspect daemon.log / an existing lock' >&2; exit 1; }
        sleep 1
    done
    echo 'Battery audit enabled; no wake lock.' ;;
 stop)
    rm -f "$vst_base/enabled"
    if [ -f "$vst_base/pid" ]; then
        vst_pid=$(cat "$vst_base/pid")
        case "$vst_pid" in ''|*[!0-9]*) exit 1 ;; esac
        if tr '\000' ' ' < "/proc/$vst_pid/cmdline" 2>/dev/null | grep -q 'vst-power-audit/record.sh'; then
            vst_group=$(awk '{print $5}' "/proc/$vst_pid/stat")
            vst_sid=$(awk '{print $6}' "/proc/$vst_pid/stat")
            # Stop only the dedicated session created by start's setsid.
            if [ "$vst_group" = "$vst_sid" ] && [ "$vst_group" -gt 1 ]; then
                kill -TERM -- "-$vst_group"
            else
                kill -TERM "$vst_pid"
            fi
        fi
        rm -f "$vst_base/pid"
    fi
    echo 'Battery audit stopped; logs retained.' ;;
 status)
    if [ -f "$vst_base/enabled" ]; then echo enabled; else echo disabled; fi
    [ ! -f "$vst_base/pid" ] || { printf 'PID='; cat "$vst_base/pid"; }
    /data/adb/magisk/busybox du -sh "$vst_base/sessions" 2>/dev/null || true ;;
 *) echo 'Use start, stop or status' >&2; exit 64 ;;
esac
