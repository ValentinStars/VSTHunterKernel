# VSTHunterKernel — Samsung Galaxy A51 / Exynos 9611 (universal9611)

Linux 4.14.364 for SM-A515F / universal9611, maintained by Valentin Stars.
Alpha5 was built and boot-tested on Evolution X Android 16 with Magisk 30.7.
Other ROM/device combinations need separate validation.

## Source lineage

This is a downstream fork of Samsung universal9611 kernel sources for Galaxy A51
(SM-A515F / Exynos 9611), with NetHunter and phone-specific fixes.
The inherited build script references the NetHunter base maintained by
[akabul0us](https://github.com/akabul0us/android_kernel_samsung_universal9611),
whose upstream is
[Exynos9611Development](https://github.com/Exynos9611Development/android_kernel_samsung_universal9611).
This GitHub repository was created by importing the source history, so GitHub
currently shows it as an independent repository rather than a native fork link.
Kernel and firmware authors retain their original credits and licenses.

## Alpha5

[Release notes](RELEASE_NOTES_ALPHA5.md) list the fixes, test results and remaining
issues. [Phone helpers](tools/alpha5/README.md) explain the separate ROM recursion
workaround and the inspected chroot setup.

Download: [v2.0-Alpha5.1 prerelease](https://github.com/ValentinStars/VSTHunterKernel/releases/tag/v2.0-Alpha5.1).
This hotfix was built locally and boot-tested; see the release for its exact source
revision and checksums.
The kernel ZIP, Magisk module bundle and ROM patcher source are separate assets.
The ROM overlay must be generated locally; it is not included in the kernel ZIP.

## Effective build configuration

- SCSC internal Wi-Fi with link-layer statistics disabled for the observed HAL bug.
- USB Wi-Fi: ath9k_htc, carl9170, ath6kl/ath10k USB, rt2800usb, mt7601u,
  zd1211rw and the enabled rtw88 USB variants in vstnh_defconfig.
- WireGuard, BBR, packet filtering, TTL/HL targets and NFQUEUE.
- USB configfs HID, ACM, RNDIS and mass storage; USB serial CH341, CP210x,
  FTDI and PL2303.
- RTL28xxU, AirSpy, HackRF and MSI2500 drivers.
- SocketCAN, vcan and slcan; slcan and br_netfilter are loadable modules.
- ZRAM with ZSTD and multigenerational LRU.

Compiled driver support does not establish that each external adapter was
hardware-tested. Firmware files alone do not imply that a driver is enabled.
See the effective config for exact symbols. OTG current limits are not controlled
by the status helper. Runtime memory savings and battery life are not guaranteed.

## Build

Provide the inspected Neutron Clang 18 toolchain and host build dependencies:
make, Clang-compatible build tools, zip, Python 3 and standard kernel prerequisites.

```sh
VST_TOOLCHAIN_DIR=/absolute/path/Neutron_Clang_18 ./build_kernel.sh
./build_magisk_modules.sh
```

Optional environment variables: VST_OUT_DIR, VST_JOBS and VST_CONFIG.
The script checks pinned firmware, builds Image and modules, then packages
AnyKernel3. Kernel output defaults to out_alpha5; modules to magisk_release_zips.
Missing toolchains or failed builds terminate without packaging stale outputs.

## Phone helper scope

The SD/chroot module was written for the inspected phone's SD UUID, image path
and Kali/ANDRAX/Stryker roots. Review those paths before using it elsewhere.
Retain boot and rootfs backups. Installation and rollback details are in the
release notes. Private ROM jars, boot images, application data and device logs
are excluded from published assets.

## Source licenses

Kernel licensing is described in [COPYING](COPYING). Bundled firmware provenance,
checksums and vendor redistribution terms are in
[firmware/ALPHA5_FIRMWARE.md](firmware/ALPHA5_FIRMWARE.md).

## Automation and diagnostics

[Manual GitHub Actions builds](docs/CI.md) can package and publish a prerelease
from a selected branch. Ordinary commits do not consume build runs.
[Passive battery audit](tools/power-audit/README.md) records charging/discharge,
wake sources, CPU/memory snapshots and system warnings without changing LiveBoot
colors or suppressing logs. Graphs state the driver measurement limitations.

[TTMod Android 16 crash report](docs/bugs/TTMOD_ANDROID16.md) documents the local
app compatibility investigation. [Alpha5 session status](RELEASE_NOTES_ALPHA5.md)
separates tested fixes from long-term battery/RAM/watchdog checks.

[Open investigations and test plans](docs/OPEN_ISSUES.md) track the remaining
battery, SystemUI, stats service, RAM and watchdog work.
