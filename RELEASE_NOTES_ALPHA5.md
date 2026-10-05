# VSTHunterKernel v2.0-Alpha5 — A51 fixes

Prerelease tested on a rooted **SM-A515F / universal9611**, Evolution X Android
16, Magisk 30.7. Other phones/ROMs are not validated by this session.

## Changes

- Use the extracted effective Alpha4 configuration as the build baseline.
  Clear the forced fatal-init/recovery and diagnostic-suppression cmdline.
- Disable SCSC link-layer statistics by default to avoid the observed vendor
  Wi-Fi HAL rate-statistics decoding crash. Statistics telemetry is unavailable.
- Fix a preemptible per-CPU networking read without suppressing kernel warnings.
- Restore the earlier SIOP charging limits and remove a defective wakelock-name
  filter. Battery life and offline charging still require measurement.
- Correct compiler metadata, align module vermagic, include required firmware
  with checksums/licenses, and fail builds when prerequisites/artifacts are absent.
- Serialize SD image mounting and chroot preparation. Remove duplicate automatic
  fsck hooks and the exFAT checker bypass. Preserve shell arguments and the root
  account's login shell. Allocate a controlling PTY for interactive Magisk sessions.
- Make Chroot Manager status/export work with the canonical SD-image mount.
  Exports exclude Android mounts and refuse active sessions. Directory restore
  and removal are unsupported for the image-backed rootfs.
- Correct custom module scripts: no unconditional VPN forwarding, no recursive
  SDR device permission rewrite, validate Wi-Fi operations, report USB OTG
  status instead of writing unrelated charging controls, retain real hardware identity.
- Set kernel/runtime hostname to VST. Inspected chroot hostname files were
  updated with backups on the phone.

## ROM-specific soft-reboot fix

The observed `ComputerEngine.canHideApp -> getNameForUid` recursion was patched
with a local Magisk overlay. The workaround **disables Evolution app hiding**.
The phone booted with the overlay and passed on-device DEX verification.

**The kernel ZIP and module bundle do not contain this ROM overlay.**
`tools/alpha5/patch_services.py` generates it from the owner's matching local
services.jar. Instructions and the inspected input hash are in
`tools/alpha5/README.md`. The ROM jar and private boot/SD backups are not published.

## Session results and remaining work

| Report | Result |
| --- | --- |
| Random soft reboots | Observed framework recursion bypassed; short observation without another crash; long-term check pending |
| Termux after reboot | Orphan Termux X11 shared UID removed with backup; user confirms Termux works |
| SIM after reboot | User confirms network works; repeated outgoing-call validation remains |
| Battery drain | Unsafe power changes removed; unplugged baseline comparison pending |
| Random watchdog | Forced fatal init settings removed; separate watchdog reproduction pending |
| Offline charging watchdog | User deferred physical test |
| Wi-Fi LAN drops | Statistics workaround; 96 MiB short LAN checksum test passed |
| RAM drops | Baseline recorded; no leak fix claimed |
| TikTok / Exteragram | ART crashes in modified TikTok remain; Anti-Spoiler disabled reversibly for Exteragram ANR; user confirms app works after reboot |
| Kali SD I/O | Full 15 GiB backup, offline metadata repair, clean recheck, 32 MiB fsync/direct-read checksum test passed |
| Ctrl+C ends terminals | PTY tests passed for Kali/ANDRAX/Stryker launchers; app-specific confirmation remains |
| Logcat errors | Concrete framework/Wi-Fi/Termux causes addressed; logcat is not expected to be globally empty |
| Chroot Manager | Canonical status, mount ownership and safe image export fixed; directory install lifecycle not supported for mounted image |
| nh shell/profile mismatch | Same canonical root and configured login shell; no P10K configuration invented |
| Hostname VST | Kernel/runtime and inspected rootfs hostname files updated |
| Custom modules/programs | Scripts corrected and nine module ZIPs rebuilt; application-specific issues remain as above |
| Alpha5 release | Kernel/source/module artifacts published as a prerelease |

## Install and rollback

For the tested A51 setup, retain a verified original boot backup and use the
AnyKernel kernel ZIP through the existing compatible installation method.
Install selected module ZIPs through Magisk and reboot. The SD helper is
specific to the inspected UUID/image/root paths; review it before use elsewhere.
The included slcan.ko and br_netfilter.ko match Alpha5, not other kernel releases.

The local framework workaround is a separate installation. Disable its module
`vst_evolution_pm_fix` from recovery/root if rollback is needed. Source scripts
keep inspected original app hooks under `/data/adb/vst-alpha5-backup`.
Do not restore the old automatic live-fsck or fake exFAT checker hooks.

Phone-specific boot images and user data are excluded. Published SHA256SUMS
covers all release assets except the checksum file itself.
