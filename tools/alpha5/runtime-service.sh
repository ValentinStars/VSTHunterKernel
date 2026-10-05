#!/system/bin/sh
# Root hostname and legacy HAL statistics workaround; no Android ID spoofing.
printf '%s\n' VST > /proc/sys/kernel/hostname
if [ -w /sys/module/scsc_wlan/parameters/lls_disabled ]; then
    printf '%s\n' 1 > /sys/module/scsc_wlan/parameters/lls_disabled
fi

# This ROM leaves the declared APEX statsd service disabled. Binder clients then
# wait every second indefinitely. Let init start its existing service with the
# declared UID, sockets and SELinux context; never launch the binary as root.
if [ "$(getprop ro.evolution.build.version)" = EvolutionX-16.0-20260221-a51-11.6.1-Vanilla-Unofficial ] &&
   [ "$(getprop ro.build.version.sdk)" = 36 ] &&
   [ ! -e /data/adb/vst-disable-statsd-workaround ]; then
    vst_wait=0
    while [ "$(getprop apex.all.ready)" != true ]; do
        [ "$vst_wait" -lt 120 ] || exit 0
        sleep 1
        vst_wait=$((vst_wait + 1))
    done
    if [ -x /apex/com.android.os.statsd/bin/statsd ] &&
       [ -f /apex/com.android.os.statsd/etc/init.rc ] &&
       [ "$(getprop init.svc.statsd)" != running ]; then
        if ! setprop ctl.start statsd; then
            log -p e -t VST-Runtime 'init refused statsd startup'
            exit 1
        fi
        sleep 2
        if [ "$(getprop init.svc.statsd)" != running ]; then
            log -p e -t VST-Runtime 'statsd did not remain running; inspect init/statsd logs'
            exit 1
        fi
        log -p i -t VST-Runtime 'Started declared statsd service for EvolutionX 20260221'
    fi
fi
