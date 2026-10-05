#!/system/bin/sh
# Passive sampling: no wake lock, alarm, screen wakeup or power setting changes.
set -eu
vst_base=/data/adb/vst-power-audit
vst_bb=/data/adb/magisk/busybox
mkdir -p "$vst_base/sessions"
chmod 700 "$vst_base" "$vst_base/sessions"
if [ "${1:-}" != --locked ]; then
    exec "$vst_bb" flock -n "$vst_base/record.lock" /system/bin/sh "$0" --locked
fi
printf '%s\n' "$$" > "$vst_base/pid"
trap 'rm -f "$vst_base/pid"' EXIT
trap 'exit 0' TERM INT
vst_boot=$(cat /proc/sys/kernel/random/boot_id)
vst_dir="$vst_base/sessions/$(date -u +%Y%m%dT%H%M%SZ)-$vst_boot"
mkdir "$vst_dir"
cat > "$vst_dir/README.txt" <<'EOF'
Samples normally every 60 seconds. Deep sleep can delay samples: use actual timestamps.
No wake lock or alarm is acquired. Snapshot collection itself consumes some energy.
Samsung current_now is mA; batt_current_ua_now is uA. Zero readings are not proof of zero consumption.
charge_counter is computed from full capacity and SOC by sm5713_fuelgauge.c; it is not a measured coulomb counter.
Raw SOC has 0.1% hardware resolution despite the x100 representation.
Logs can contain private app/network details. They are stored locally with root-only access.
EOF
uname -a > "$vst_dir/kernel.txt"
getprop ro.build.version.release > "$vst_dir/android.txt"
printf '%b\n' 'epoch_s	boot_id	uptime_s	capacity_pct	raw_soc_x100	charge_counter_uah_est	voltage_uv	current_now_ma	current_ua	current_avg_ua	status	usb_online	ac_online	wireless_online	temp_deci_c	brightness	mem_available_kb	swap_free_kb	cpu0_khz	cpu4_khz	charging_enabled	charging_type	wakefulness	sample_cost_s' > "$vst_dir/samples.tsv"
vst_read() {
    vst_scalar=NA
    if [ -r "$1" ]; then IFS= read -r vst_scalar < "$1" || true; fi
    printf '%s' "${vst_scalar:-NA}"
}
vst_count=0
vst_previous_status=
while [ -f "$vst_base/enabled" ]; do
    vst_start=$(cut -d ' ' -f 1 /proc/uptime)
    vst_epoch=$(date +%s)
    vst_bat=/sys/class/power_supply/battery
    vst_values=
    for vst_key in capacity batt_read_raw_soc charge_counter voltage_now current_now batt_current_ua_now batt_current_ua_avg status; do
        vst_value=$(vst_read "$vst_bat/$vst_key")
        vst_values="$vst_values\t$vst_value"
        [ "$vst_key" != status ] || vst_status=$vst_value
    done
    for vst_path in /sys/class/power_supply/usb/online /sys/class/power_supply/ac/online /sys/class/power_supply/wireless/online "$vst_bat/temp" /sys/class/backlight/panel/brightness; do
        vst_values="$vst_values\t$(vst_read "$vst_path")"
    done
    vst_mem=$(awk '/^MemAvailable:/ {a=$2} /^SwapFree:/ {s=$2} END {printf "%s\t%s",a,s}' /proc/meminfo)
    # Do not depend on uninitialised shell state for optional sensors.
    vst_after=
    for vst_path in /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq "$vst_bat/charging_enabled" "$vst_bat/charging_type"; do
        vst_after="$vst_after\t$(vst_read "$vst_path")"
    done
    dumpsys power > "$vst_dir/power-latest.txt" 2>/dev/null || true
    vst_wake=$(awk -F= '/mWakefulness=/ {print $2; exit}' "$vst_dir/power-latest.txt")
    vst_end=$(cut -d ' ' -f 1 /proc/uptime)
    vst_cost=$(awk -v a="$vst_start" -v b="$vst_end" 'BEGIN {printf "%.2f",b-a}')
    printf '%b\n' "$vst_epoch\t$vst_boot\t$vst_start$vst_values\t$vst_mem$vst_after\t${vst_wake:-NA}\t$vst_cost" >> "$vst_dir/samples.tsv"
    if [ $((vst_count % 10)) = 0 ] || [ "$vst_status" != "$vst_previous_status" ]; then
        vst_stamp="$vst_epoch-$vst_count"
        vst_temp="$vst_dir/snapshot-$vst_stamp"
        mkdir "$vst_temp"
        cp "$vst_dir/power-latest.txt" "$vst_temp/power.txt"
        for vst_proc in stat meminfo vmstat interrupts diskstats net/dev pressure/cpu pressure/memory pressure/io; do
            vst_name=$(printf '%s' "$vst_proc" | tr / _)
            cat "/proc/$vst_proc" > "$vst_temp/$vst_name.txt" 2>/dev/null || true
        done
        ps -A -o PID,UID,NAME,RSS,TIME > "$vst_temp/processes.txt" 2>/dev/null || true
        for vst_supply in /sys/class/power_supply/*; do
            cat "$vst_supply/uevent" >> "$vst_temp/power-supplies.txt" 2>/dev/null || true
        done
        "$vst_bb" awk '
            FNR==1 {split(FILENAME,p,"/"); keys[p[5]]=1; v[p[5],p[6]]=$0}
            END {for (k in keys) printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", k,v[k,"name"],v[k,"active_count"],v[k,"event_count"],v[k,"wakeup_count"],v[k,"total_time_ms"],v[k,"prevent_suspend_time_ms"]}
        ' /sys/class/wakeup/wakeup*/name /sys/class/wakeup/wakeup*/active_count /sys/class/wakeup/wakeup*/event_count /sys/class/wakeup/wakeup*/wakeup_count /sys/class/wakeup/wakeup*/total_time_ms /sys/class/wakeup/wakeup*/prevent_suspend_time_ms > "$vst_temp/wakeup.tsv" 2>/dev/null || true
        dumpsys batterystats --checkin > "$vst_temp/batterystats-checkin.txt" 2>/dev/null || true
        dumpsys activity lastanr > "$vst_temp/lastanr.txt" 2>/dev/null || true
        dmesg > "$vst_temp/dmesg.txt" 2>/dev/null || true
        logcat -b all -d -v threadtime -t 2000 '*:W' > "$vst_temp/logcat-warnings.txt" 2>/dev/null || true
        "$vst_bb" tar -czf "$vst_temp.tar.gz" -C "$vst_dir" "${vst_temp##*/}"
        rm -rf "$vst_temp"
        sync
        vst_snapshot_end=$(cut -d ' ' -f1 /proc/uptime)
        printf '%s\t%s\t%s\n' "$vst_epoch" "$vst_start" "$vst_snapshot_end" >> "$vst_dir/snapshot-cost.tsv"
        vst_size=$("$vst_bb" du -sk "$vst_base/sessions" | cut -f1)
        vst_free=$(df -k /data | awk 'END {print $4}')
        if [ "$vst_size" -gt 262144 ] || [ "$vst_free" -lt 153600 ]; then
            printf 'Stopped to preserve storage: epoch=%s size_kb=%s free_kb=%s\n' "$vst_epoch" "$vst_size" "$vst_free" >> "$vst_base/daemon.log"
            rm -f "$vst_base/enabled"
            exit 0
        fi
    fi
    vst_count=$((vst_count + 1))
    vst_previous_status=$vst_status
    sleep 60
done
