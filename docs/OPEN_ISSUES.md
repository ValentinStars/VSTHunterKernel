# Remaining investigations

LiveBoot's color settings and severity rendering are preserved. Errors are
collected, not hidden by changing console/log levels. The current known items
include ROM/vendor issues as well as kernel code.

| Area | Current evidence | Next check |
| --- | --- | --- |
| Battery autonomy | Full cycle collected: current readings work off USB; charge_counter is derived from SOC. TikTok leads observed app CPU and Android model estimates | Compare screen use with quiet idle intervals; check background wake sources and repeat controlled idle tests; keep charge/discharge phases separate |
| SystemUI NetworkTraffic | Controlled Dozing test: arrows on produced 1278 layout warnings/12s, arrows off 0/12s; restoring arrows reproduced 448/8s | Compact indicator applied: speed remains enabled, arrows hidden. ROM source patch prepared; compile and test it before restoring arrows |
| stats daemon | Starting through init restored binder stats; the runtime hook also passed the hotfix reboot | Exact EvolutionX 20260221 workaround verified on one reboot; investigate why ROM startup omitted it |
| Launcher ANR | One focused-window timeout before the hotfix reboot; main thread was idle when dumped | Correlate window/focus lifecycle at first unlock; the saved stack does not establish a main-thread deadlock |
| Watchdog / offline charging | Original init fatal flags removed; no certified offline charging test | Preserve pstore before reboot; supervised powered-off charging test with hardware recovery available; correlate blocked process/driver |
| RAM | Minute MemAvailable/SwapFree plus process RSS, vmstat and pressure snapshots | Compare slopes over repeated workloads; distinguish reclaim/slab growth from a reproducible leak; patch only the confirmed allocation/lifecycle bug |
| Wi-Fi LAN | Before the getter hotfix reboot, 1200 MiB TCP over 10 minutes passed SHA256; wlan0 and Wi-Fi HAL stayed stable | Repeat real LAN workloads and longer idle transitions; vendor rate-stat ABI remains a workaround |
| SIM | User confirms network works | Repeated outgoing calls after normal unlock/reboot; correlate RIL/IMS state only if failure returns |
| Exteragram | Anti-Spoiler disabled; user confirms app works | Long use; inspect plugin/GIL/UI blocking before re-enabling hot-path Python hook |
| TTMod | Five cold starts passed, but two later SIGSEGVs remained. Exact ART callsite is mirror::Class::SetStatus; hook initialization/publication needs investigation | Updated developer report; inspect SetClassStatus original callback and ShadowHook initialization on SDK36. Visibility workaround alone is insufficient |
| Chroot lifecycle | Program/I/O/local-network checks and busy export/unmount rejection passed for the live setup; default-shell Ctrl+C passed in three roots | Busy session handling and real export/restore-on-copy tests; original image removal/install is intentionally not done through directory operations |

New kernel finding: sec_battery advertised two control reads but returned success
without assigning val->intval. Live sysfs exposed arbitrary integers. Source now
returns -ENODATA for these write-only reads; setters remain supported. This change
was compiled and installed from d810c755d. Both reads returned ENODATA after
reboot; uevent no longer contains arbitrary control values. Root, charging,
matching slcan, statsd and the persistent recorder passed the reboot check.
After this reboot, the user confirmed Termux works and TTMod opened on the first
attempt in about 20 seconds. Slow startup and the previously recorded late native
crashes remain open; successful launch does not establish long-term stability.

Host storage: offline F2FS repair and a full dry-run recheck passed. A subsequent
fresh Kali-backup copy failed checksums and zstd decoding. A targeted retry
passed a full reread after file-cache eviction. Later a previously verified
legacy Image failed a fresh SHA256 reread too. The volume is now read-only;
laptop originals and the pre-repair partition backup are retained. The cause
is not isolated to hardware or filesystem code; sole-copy migration is unsafe.

Clean-build finding: converted Samsung firmware was generated in the output tree,
but the assembly wrapper referenced the source tree. Correct the `.incbin` path
for generated blobs while preserving source paths for prebuilt firmware. This
was masked by previously generated files; a fresh checkout must compile without
manually copying ignored `.fw` files into the source tree.

The statsd workaround can be skipped by creating
`/data/adb/vst-disable-statsd-workaround`. It does not replace the daemon, change
its UID or silence logging. Live recovery and one reboot startup are verified.
Aconfig socket services are separate and remain under
investigation.

New ROM/application finding: an incoming call produced 162 com.android.dialer
SecurityException crashes when its fallback InCallService tried a phoneCall
foreground service while Koler held the DIALER role. The user requests keeping
Koler. Do not disable the system fallback InCallService or bypass Android's
foreground-service permission checks; investigate fallback selection and fix
the ROM/Dialer source. The previous SIM registration result does not close this
separate call-UI defect. No calls were placed automatically.
