# Sourced by Magisk's installer.
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755
for vst_script in service.sh prepare-chroot.sh; do
    set_perm "$MODPATH/$vst_script" 0 0 0755
done
vst_backup=/data/adb/vst-alpha5-backup
mkdir -p "$vst_backup/disabled-hooks" "$vst_backup/nethunter-scripts"
# Magisk also runs files with renamed suffixes inside these hook directories.
for vst_hook in /data/adb/service.d/01_mount_vst_nethunter.sh /data/adb/post-fs-data.d/00_fix_fsck.sh /data/adb/service.d/*.alpha4-disabled /data/adb/post-fs-data.d/*.alpha4-disabled; do
    [ ! -f "$vst_hook" ] || mv "$vst_hook" "$vst_backup/disabled-hooks/"
done
vst_scripts=/data/data/com.offsec.nethunter/scripts
if [ -f "$vst_scripts/bootkali_init" ]; then
    vst_hash=$(sha256sum "$vst_scripts/bootkali_init"); vst_hash=${vst_hash%% *}
    if [ "$vst_hash" = bfde98f8555dd0fb80325bfe04c2a09530eb0ccc5d12bdbb412be5e58b412a66 ]; then
        [ -f "$vst_backup/nethunter-scripts/bootkali_init" ] || cp -a "$vst_scripts/bootkali_init" "$vst_backup/nethunter-scripts/"
        cp "$MODPATH/bootkali_init.sh" "$vst_scripts/bootkali_init"
        chmod 755 "$vst_scripts/bootkali_init"
    fi
fi
if [ -f "$vst_scripts/bootkali_env" ]; then
    vst_hash=$(sha256sum "$vst_scripts/bootkali_env"); vst_hash=${vst_hash%% *}
    if [ "$vst_hash" = 3595e2ba2ddd77dd17b86cd558616b19738a6733f2879888d6cf63bc7cff511d ]; then
        [ -f "$vst_backup/nethunter-scripts/bootkali_env" ] || cp -a "$vst_scripts/bootkali_env" "$vst_backup/nethunter-scripts/"
        awk '
            /^# Auto-mount NetHunter SD image/ {skip=1}
            /^MNT=/ && skip {
                print "if [ ! -e /data/adb/vst-kali-maintenance ]; then"
                print "    /system/bin/sh /data/adb/modules/vst-nethunter-sd-fix/service.sh || return 1"
                print "fi"
                skip=0
            }
            !skip {print}
        ' "$vst_scripts/bootkali_env" > "$vst_scripts/bootkali_env.alpha5"
        cat "$vst_scripts/bootkali_env.alpha5" > "$vst_scripts/bootkali_env"
        rm "$vst_scripts/bootkali_env.alpha5"
    fi
fi
