# Alpha5 embedded firmware

These files are the firmware inputs already used by the inspected Alpha4 build.
The exact bytes are recorded in `alpha5-firmware.sha256`. Binary firmware was
excluded by the global file patterns in `.gitignore`; the required build inputs
are explicitly tracked for Alpha5.

- Realtek rtw88/rtlwifi: `LICENCE.rtlwifi_firmware.txt`.
- Ralink/MediaTek: `LICENCE.ralink-firmware.txt`.
- ath9k_htc `htc_9271.fw` and `htc_7010.fw`: GPLv2; source at
  https://github.com/qca/open-ath9k-htc-firmware.
- `carl9170-1.fw`: GPLv2; source at
  https://github.com/chunkeey/carl9170fw.

Firmware upstream and license records:
https://gitlab.com/kernel-firmware/linux-firmware
https://kernel.googlesource.com/pub/scm/linux/kernel/git/firmware/linux-firmware.git/+/refs/tags/20250211/
