# 🚀 VSTHunterKernel (VSTnh) v2.0-Alpha3 — Release Notes

**Release Date:** August 26, 2026  
**Codename:** `hakirfon`  
**Kernel String:** `Linux hakirfon 4.14.364-NetHunter-VST-Alpha3`  
**Target Device:** Samsung Galaxy A51 (SM-A515F / universal9611)  
**Supported Android Versions:** Android 13, 14, 15, and 16 (Evolution X / AOSP)  
**Author:** Valentin Stars ([Telegram: @vstbio](https://vstbio.t.me))

---

## 🌟 What's New in Alpha3

### 1. 📡 Full In-Kernel Aircrack-ng RTL8812AU Driver Stack
- **Official Aircrack-ng RTL8812AU / RTL8814AU / RTL8821AU Integration**: High-power Wi-Fi pentest driver built directly into the kernel image (`CONFIG_88XXAU=y`).
- **Built-in Microcode / Firmware**: Firmware headers embedded inside the driver code for 100% plug-and-play monitor mode, VHT packet injection, and channel hopping without missing firmware errors.
- **Full TX Power and LED Control**: Supports 30dBm (1000mW) transmission power and custom injection modes for Alfa AWUS036ACH.

---

### 2. 🔌 Automated In-Kernel Firmware Loading (`CONFIG_EXTRA_FIRMWARE`)
- **Pre-baked Extra Firmware Blobs**: The kernel now natively embeds all necessary microcode blobs directly into the binary:
  - `rtw88/rtw8822c_fw.bin`, `rtw88/rtw8822b_fw.bin`, `rtw88/rtw8821c_fw.bin`, `rtw88/rtw8723d_fw.bin`, `rtw88/rtw8814a_fw.bin`, `rtw88/rtw8821a_fw.bin`, `rtw88/rtw8812a_fw.bin`
  - Qualcomm Atheros `htc_9271.fw`, `htc_7010.fw` (TL-WN722N v1, Alfa AWUS036NHA)
  - `carl9170-1.fw`
  - Realtek `rtlwifi/rtl8188efw.bin`, `rtlwifi/rtl8192cufw_TMSC.bin`, `rtlwifi/rtl8192eufw.bin`
  - Ralink `rt2870.bin` (RT3070, RT3572, RT5370)
  - MediaTek `mt7601u.bin`
- Adapters initialize instantly upon USB connection with zero delay.

---

### 3. 🧩 Complete Magisk Modules Suite v2.0-Alpha3
- **New Module `00_VST_NetHunter_SD_AutoFix.zip`**:
  - Automatically bypasses Android Vold filesystem locks (`fsck.exfat`) for seamless MicroSD rootfs mounting.
  - Persistent background automount daemon for Kali/Andrax container (`kali_arm64.img`).
  - Patches NetHunter App lifecycle (`killkali`, `chrootmgr`).
  - Installs multi-suite CLI shortcuts: `nh`, `stryker`, `andrax`, `pentest`, `hack`, `vst`.
- **Module `03_VST_Wireless_Pentest_Arsenal.zip`**: Complete firmware tree deployed to `/system/etc/firmware/` with `vst-wifi` CLI.
- **Module `05_VST_Hardware_Hacking_CAN.zip`**: Updated with freshly compiled `slcan.ko` module for SocketCAN.
- **Module `06_VST_hakirfon_Edition_SystemProp.zip`**: Spoofs system properties to `hakirfon Alpha3 - Valentin Stars`.

---

## 📦 Package List

1. **Kernel Image & Installer**:
   - `VSTHunterKernel-A51-NetHunter-VST-Alpha3.zip` (AnyKernel3 Flashable Zip)
2. **Magisk Modules Pack**:
   - `00_VST_NetHunter_SD_AutoFix.zip`
   - `01_VST_BadUSB_NetHunter_Arsenal.zip`
   - `02_VST_WireGuard_Toolkit.zip`
   - `03_VST_Wireless_Pentest_Arsenal.zip`
   - `04_VST_SDR_Radio_Hacker.zip`
   - `05_VST_Hardware_Hacking_CAN.zip`
   - `06_VST_hakirfon_Edition_SystemProp.zip`
   - `07_VST_USB_OTG_Power_Switcher.zip`
