# Remaining investigations

LiveBoot's color settings and severity rendering are preserved. Errors are
collected, not hidden by changing console/log levels. The current known items
include ROM/vendor issues as well as kernel code.

| Area | Current evidence | Next check |
| --- | --- | --- |
| Battery autonomy | Full cycle collected: current readings work off USB; charge_counter is derived from SOC. TikTok leads observed app CPU and Android model estimates | Compare screen use with quiet idle intervals; check background wake sources and repeat controlled idle tests; keep charge/discharge phases separate |
| SystemUI NetworkTraffic | Controlled Dozing test: arrows on produced 1278 layout warnings/12s, arrows off 0/12s; restoring arrows reproduced 448/8s | Compact indicator applied: speed remains enabled, arrows hidden. ROM source patch prepared; compile and test it before restoring arrows |
| stats daemon | APEX contains a disabled init service, but no daemon was running. Starting through `ctl.start statsd` restored binder `stats`; repeated client waits stopped | Runtime hook starts the declared service on the exact EvolutionX 20260221 build only. Check next boot and longer use; investigate why ROM startup omitted it |
| Launcher ANR | One focused-window timeout during the latest boot | Read the saved ANR main-thread stack and correlate first unlock, SystemUI load and stats service |
| Watchdog / offline charging | Original init fatal flags removed; no certified offline charging test | Preserve pstore before reboot; supervised powered-off charging test with hardware recovery available; correlate blocked process/driver |
| RAM | Minute MemAvailable/SwapFree plus process RSS, vmstat and pressure snapshots | Compare slopes over repeated workloads; distinguish reclaim/slab growth from a reproducible leak; patch only the confirmed allocation/lifecycle bug |
| Wi-Fi LAN | 1200 MiB TCP stream over 10 minutes passed SHA256; wlan0 stayed connected and Wi-Fi HAL PID stayed unchanged | Repeat real LAN workloads and longer idle transitions; vendor rate-stat ABI remains a workaround |
| SIM | User confirms network works | Repeated outgoing calls after normal unlock/reboot; correlate RIL/IMS state only if failure returns |
| Exteragram | Anti-Spoiler disabled; user confirms app works | Long use; inspect plugin/GIL/UI blocking before re-enabling hot-path Python hook |
| TTMod | Five cold starts passed, but two later SIGSEGVs remained. Exact ART callsite is mirror::Class::SetStatus; hook initialization/publication needs investigation | Updated developer report; inspect SetClassStatus original callback and ShadowHook initialization on SDK36. Visibility workaround alone is insufficient |
| Chroot lifecycle | Mount, PTY, status and export checks passed | Busy session handling and real export/restore-on-copy tests; original image removal/install is intentionally not done through directory operations |

New kernel finding: sec_battery advertised two control reads but returned success
without assigning val->intval. Live sysfs exposed arbitrary integers. Source now
returns -ENODATA for these write-only reads; setters remain supported. This change
is pending compilation/device validation and is not yet in the installed Image.

Host storage: offline F2FS repair and a full dry-run recheck passed. A subsequent
fresh copy of the Kali backup nevertheless failed content checksums and zstd
decoding. A targeted retry passed a full reread after file-cache eviction, but
the initial corruption is unexplained. Laptop originals remain available;
filesystem consistency alone does not establish reliable backup storage.

Clean-build finding: converted Samsung firmware was generated in the output tree,
but the assembly wrapper referenced the source tree. Correct the `.incbin` path
for generated blobs while preserving source paths for prebuilt firmware. This
was masked by previously generated files; a fresh checkout must compile without
manually copying ignored `.fw` files into the source tree.

The statsd workaround can be skipped by creating
`/data/adb/vst-disable-statsd-workaround`. It does not replace the daemon, change
its UID or silence logging. The live recovery is verified; its next-boot path
has not yet been tested. Aconfig socket services are separate and remain under
investigation.
