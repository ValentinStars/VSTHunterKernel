#!/system/bin/sh
# Root hostname and legacy HAL statistics workaround; no Android ID spoofing.
printf '%s\n' VST > /proc/sys/kernel/hostname
if [ -w /sys/module/scsc_wlan/parameters/lls_disabled ]; then
    printf '%s\n' 1 > /sys/module/scsc_wlan/parameters/lls_disabled
fi
