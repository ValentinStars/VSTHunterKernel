# 🚀 VSTHunterKernel (VSTnh) v2.0-Alpha3.1 — Release Notes

**Release Date:** August 27, 2026  
**Codename:** `hakirfon`  
**Kernel String:** `Linux hakirfon 4.14.364-NetHunter-VST-Alpha3.1`  
**Target Device:** Samsung Galaxy A51 (SM-A515F / universal9611)  
**Supported Android Versions:** Android 13, 14, 15, and 16 (Evolution X / AOSP)  
**Author:** Valentin Stars ([Telegram: @vstbio](https://vstbio.t.me))

---

## 🌟 What's New in Alpha3.1

### 1. 🖥️ Framebuffer Console & Virtual Terminals (`CONFIG_VT` & `CONFIG_FRAMEBUFFER_CONSOLE`)
- **Direct AMOLED Display Console Binding**: Samsung DECON display controller binds directly to `/dev/graphics/fb0`.
- **Text Console on Screen**: Real Linux VT console with rotation support (`CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y`) and built-in scalable console fonts.

### 2. 🐧 Linux Tux 224-Color Logo (`CONFIG_LOGO_LINUX_CLUT224`)
- **Full-Color Linux Boot Logo**: Displays the classic 224-color Linux Tux penguin directly on the AMOLED screen during kernel initialization.

### 3. 💥 AMOLED Crash Screen & Kernel Panic (`console=tty0 panic=0`)
- **Screen Kernel Panic**: `dmesg` output and `panic()` stack traces are printed directly onto the AMOLED screen.
- **Freeze on Panic**: `panic=0` keeps the crash dump on screen without auto-rebooting after 5 seconds, making low-level debugging and logs inspection instant.

### 4. 🛠️ Modern Toolchain & Clang 18 LLVM LLD Optimization
- Rebuilt with **Neutron Clang 18**, optimized symbol tables, relative relocations, and clean module loading.

---

## 📦 Package List

1. **Kernel Image & Installer**:
   - `VSTHunterKernel-A51-NetHunter-VST-Alpha3.1.zip` (AnyKernel3 Flashable Zip)
2. **Magisk Modules Pack**:
   - `00_VST_NetHunter_SD_AutoFix.zip`
   - `01_VST_BadUSB_NetHunter_Arsenal.zip`
   - `02_VST_WireGuard_Toolkit.zip`
   - `03_VST_Wireless_Pentest_Arsenal.zip`
   - `04_VST_SDR_Radio_Hacker.zip`
   - `05_VST_Hardware_Hacking_CAN.zip`
   - `06_VST_hakirfon_Edition_SystemProp.zip`
   - `07_VST_USB_OTG_Power_Switcher.zip`
