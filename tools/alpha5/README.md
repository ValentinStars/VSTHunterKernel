# Alpha5 phone fixes

## Confirmed observations on the A51

- Evolution X's `ComputerEngine.canHideApp()` calls public `getNameForUid()`.
  Package visibility filtering calls `canHideApp()` again. The crash buffer
  contains this repeated recursion immediately before system_server dies.
- Wi-Fi vendor HAL crashes occur in link layer rate statistics decoding.
  The existing SCSC `lls_disabled` parameter is enabled as a workaround.
  This disables link layer statistics; it does not repair the vendor HAL ABI.
- A stale, APK-less `com.termux.x11` shared UID entry caused a notification
  service `SecurityException`. Its data was backed up and the orphan package
  entry was removed successfully. Termux data was retained.
- Two SD automounters ran independently. One ran `e2fsck -fy` without excluding
  another process mounting the image. The replacement never runs fsck.
- Interactive Magisk commands need `su -i` to allocate a controlling PTY.
  `nh.sh` uses this for login sessions. In PTY tests, Kali, ANDRAX and Stryker
  interrupted `sleep 30` with Ctrl+C and then successfully ran another command.
- Launchers now use the root account's configured shell, retain exact argument
  boundaries and execute commands once. Hostname is VST in the shared UTS
  namespace. The Kali chroot's `/etc/hostname` was updated with a backup.

Phone snapshots and backups are private local artifacts, outside this Git tree.
The kernel's effective Alpha4 configuration is the baseline for Alpha5.
Unavailable mt76/rtl8188eu sources are not advertised as compiled drivers.

## Framework overlay

`patch_services.py` takes a locally supplied ROM `services.jar`, verifies its
hash and finds the exact `canHideApp(int, String)` DEX method. It replaces the
entry with `return false`, recalculates the DEX signature/checksum and builds a
Magisk module. Evolution app hiding is disabled by this workaround. No ROM jar
is distributed in this source repository.

Source for the observed ROM code:
https://github.com/Evolution-X/frameworks_base/blob/vic/services/core/java/com/android/server/pm/ComputerEngine.java

The inspected input SHA256 is
`2c9d17b6b2efb57a77ea35e6d00bb9ece7e8747dde7b6abca8fb9df2f0880514`.
The generated jar passed on-device `dex2oat64 --compiler-filter=verify`.
The overlay loaded successfully after reboot. The first system_server remained
alive and the crash buffer was empty during the initial observation period.

```sh
python3 -m venv /tmp/a51-dex-tools
/tmp/a51-dex-tools/bin/pip install androguard==4.1.3
/tmp/a51-dex-tools/bin/python tools/alpha5/patch_services.py \
  /path/to/services-original.jar /path/to/local-fix.zip \
  --expected-sha256 2c9d17b6b2efb57a77ea35e6d00bb9ece7e8747dde7b6abca8fb9df2f0880514
```

If the module prevents Android booting, disable `vst_evolution_pm_fix` from
Magisk recovery or create `/data/adb/modules/vst_evolution_pm_fix/disable` from
an available root/recovery shell, then reboot. The original system partition
and the original jar are unchanged.

## Chroot scripts

`sd-mount.sh` owns the native SD image attachment. `prepare-chroot.sh` serializes
setup for the three known rootfs locations and retains Android's devpts for
terminal sessions. It exposes USB and TUN devices without modifying their host
permissions. `nh.sh` replaces the launcher with the chosen shell or command.
No recursive mount propagation changes, lazy unmounts, or fsck bypass are used.
These scripts require the inspected Magisk BusyBox and Magisk `su -i` support.

On the inspected phone the original module was copied to
`/data/adb/vst-alpha5-backup/vst-nethunter-sd-fix`; standalone duplicate SD/fsck
hooks were moved outside the execution directories to
`/data/adb/vst-alpha5-backup/disabled-hooks`. Renaming a suffix inside `service.d`
does not disable a Magisk hook. The original `nh_script.sh` was
backed up before becoming an `nh` wrapper. Backups must be retained for rollback.

## Still to validate

Kernel Image/modules build and boot; recurring ROM/watchdog crashes; outgoing
SIM calls after a reboot; screen-off battery consumption; long-running Wi-Fi
LAN traffic; SD image I/O; NetHunter Manager lifecycle; TikTok/Exteragram native
crashes; RAM behaviour; offline charging. The initial observations and script
checks do not establish that all these issues are fixed.
