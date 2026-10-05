# Remaining investigations

LiveBoot's color settings and severity rendering are preserved. Errors are
collected, not hidden by changing console/log levels. The current known items
include ROM/vendor issues as well as kernel code.

| Area | Current evidence | Next check |
| --- | --- | --- |
| Battery autonomy | Passive recorder installed; current sensors report zero; charge_counter is derived from SOC | Cable unplugged normal use/idle cycle, then charging cycle; SOC/temperature/wake/CPU comparison, controlled repeats |
| SystemUI NetworkTraffic | Controlled Dozing test: arrows on produced 1278 layout warnings/12s, arrows off 0/12s; restoring arrows reproduced 448/8s | Compact indicator applied: speed remains enabled, arrows hidden. ROM source patch prepared; compile and test it before restoring arrows |
| stats daemon | APEX contains a disabled init service, but no daemon was running. Starting through `ctl.start statsd` restored binder `stats`; repeated client waits stopped | Runtime hook starts the declared service on the exact EvolutionX 20260221 build only. Check next boot and longer use; investigate why ROM startup omitted it |
| Launcher ANR | One focused-window timeout during the latest boot | Read the saved ANR main-thread stack and correlate first unlock, SystemUI load and stats service |
| Watchdog / offline charging | Original init fatal flags removed; no certified offline charging test | Preserve pstore before reboot; supervised powered-off charging test with hardware recovery available; correlate blocked process/driver |
| RAM | Minute MemAvailable/SwapFree plus process RSS, vmstat and pressure snapshots | Compare slopes over repeated workloads; distinguish reclaim/slab growth from a reproducible leak; patch only the confirmed allocation/lifecycle bug |
| Wi-Fi LAN | Short transfer test passed after LLS workaround | Prolonged LAN stream with HAL PID/log monitoring; vendor rate-stat ABI remains a workaround |
| SIM | User confirms network works | Repeated outgoing calls after normal unlock/reboot; correlate RIL/IMS state only if failure returns |
| Exteragram | Anti-Spoiler disabled; user confirms app works | Long use; inspect plugin/GIL/UI blocking before re-enabling hot-path Python hook |
| TTMod | Visibility lookup workaround passed five cold starts and first start after reboot | Developer-side SDK36 fix and normal-use regression tests |
| Chroot lifecycle | Mount, PTY, status and export checks passed | Busy session handling and real export/restore-on-copy tests; original image removal/install is intentionally not done through directory operations |

New kernel finding: sec_battery advertised two control reads but returned success
without assigning val->intval. Live sysfs exposed arbitrary integers. Source now
returns -ENODATA for these write-only reads; setters remain supported. This change
is pending compilation/device validation and is not yet in the installed Image.

Host storage blocker: the USB F2FS volume reports inconsistent node blocks.
Offline filesystem maintenance is needed before making it the sole location of
private backups. Working tree and compressed Kali backup are currently retained
on the laptop; verified compression and build-cache removal saved about 13 GiB.

The statsd workaround can be skipped by creating
`/data/adb/vst-disable-statsd-workaround`. It does not replace the daemon, change
its UID or silence logging. The live recovery is verified; its next-boot path
has not yet been tested. Aconfig socket services are separate and remain under
investigation.
