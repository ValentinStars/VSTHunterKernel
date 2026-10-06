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

## Validation on the inspected phone

Alpha5 Image and both modules built successfully with Neutron Clang 18. The
phone booted `4.14.364-NetHunter-VST-Alpha5`, retained Magisk root and loaded
slcan with the matching vermagic. Compiler metadata now reports the actual
compiler rather than the former hardcoded Clang 20 string.

The 15 GiB Kali image was backed up completely before offline repair. e2fsck
repaired free-space counters and allocation bitmap checksums. A second offline
`e2fsck -fn` finished with exit 0. A 32 MiB fsync write and direct read inside
Kali produced identical SHA256 values. Native exFAT checking was restored;
vold reported Check OK. The mount service never performs automatic repair.

Interactive PTY tests passed for Kali, ANDRAX and Stryker. LAN transfers of
96 MiB passed checksum verification with stable Wi-Fi HAL/system_server PIDs
using the statistics workaround. This was a short test, not a long-duration
stability guarantee. The owner can mount Kali on demand after a late unlock.
Chroot Manager status uses the canonical image mount path. Its backup dispatch
keeps the image mounted, excludes Android bind mounts and refuses busy chroots.
Directory remove/restore actions are blocked for this image-backed setup;
image replacement requires an explicit offline maintenance operation.

The user confirmed Termux and the network work after reboot. The crash buffer
and last-ANR report were empty during the initial Alpha5 observation period.

Exteragram's historical ANR showed its main thread waiting in the Python
`hasMediaSpoilers` hook. The active Anti-Spoiler plugin installs this hook.
Its enabled preference was backed up and toggled off as a diagnostic workaround;
this disables automatic spoiler removal. The user confirmed Exteragram works
after the next reboot/unlock; long-duration behaviour remains to be checked.
TikTok reproduced the ART class-linker crash on Alpha5. A separate local
TTMod overlay passed five cold starts, but later crashed twice (03:30 and 07:10).
The compatibility investigation remains open; see the local overlay section below.

## Still to validate

Long-duration soft-reboot/watchdog behaviour; outgoing SIM calls after repeated
reboots; unplugged screen-off battery consumption; prolonged Wi-Fi LAN use;
RAM trends; Exteragram's normal-use result and TikTok's ART crashes. Offline
charging was deferred by the user. No claim is made that all 17 reported issues
are resolved. Full private image/boot/ROM backups are deliberately not release
assets.

## Local TTMod Android 16 overlay

The fresh Alpha5 TikTok tombstone reproduced a null call from ART SetupClass.
The hook address resolves into the installed libttmod.so, which embeds LSPlant.
The upstream report https://github.com/LSPosed/LSPlant/issues/179 describes the
optional ClassLinker visibility hook causing a similar SDK 36 failure.
Later disassembly of the exact ART build identifies the failing call through
mirror::Class::SetStatus; skipping the two visibility lookups was insufficient.
See docs/bugs/TTMOD_ANDROID16.md for the updated developer report.

`patch_tiktok_lib.py` accepts only the exact inspected ARM64 library SHA256
`45ef87b1038007c9e5692d815500617837d48da17065431cc63a6d1289b5825b`.
It changes the two optional visibility lookup names to same-length unresolved
names. No ELF offsets, executable instructions or Android ART library are changed.
The local module waits for Android boot completion, checks SDK 36 and the current
app library hash, then binds the patched copy over that app's library. A different
APK build is skipped. The private original/library/module are not release assets.

```sh
python3 tools/alpha5/patch_tiktok_lib.py /path/to/libttmod.so /path/to/local-fix.zip
```

Rollback: disable `vst_tiktok_art_fix` in Magisk and reboot. For immediate removal,
stop TikTok and unmount its library overlay from a root shell. Re-enabling the
optional hooks may reproduce the original crash. This workaround requires
further repair: normal use reproduced the crash. It is not a complete fix.

## Extended checks after Alpha5.1

[Chroot validation](../../docs/CHROOT_VALIDATION.md) records program execution,
I/O, local networking, busy-session guards and terminal corrections. PowerShell
was installed separately inside the inspected Kali image; it is not bundled in
the Magisk ZIP.
