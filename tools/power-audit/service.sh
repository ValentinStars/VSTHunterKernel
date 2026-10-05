#!/system/bin/sh
# Optional boot hook; the enabled flag survives a reboot, the recorder does not wake the phone.
[ ! -f /data/adb/vst-power-audit/enabled ] || /system/bin/sh /data/adb/vst-power-audit/control.sh start
