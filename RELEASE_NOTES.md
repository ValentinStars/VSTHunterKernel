# 🚀 VSTHunterKernel (VSTnh) v2.0-Alpha2 — Release Notes

**Release Date:** August 24, 2026  
**Codename:** `hakirfon`  
**Kernel String:** `Linux hakirfon 4.14.364-NetHunter-VST-Alpha2`  
**Target Device:** Samsung Galaxy A51 (SM-A515F / universal9611)  
**Supported Android Versions:** Android 13, 14, 15, and 16 (Evolution X / AOSP)  
**Author:** Valentin Stars ([Telegram: @vstbio](https://vstbio.t.me))

---

## 🌟 What's New in Alpha2

### 1. 🎨 New Installer Art & Branding Overhaul
- **Brand-New Compact ASCII Banner** on AnyKernel3 and all Magisk modules:
  ```text
  .-..-..---..---.                   
  | .` || |- `| |'                   
  `-'-'`---' `-'                    
                                     
  .-. .-..-..-..-..-..---..---..---. 
  | |=| || || || .` |`| |'| |- | |-< 
  `-' `-''----'`-'-' `-' `---'`-'`-' 

           ⚡ Valentin Stars (vstbio.t.me) ⚡
  ```
- **Cleaner Installer**: Removed duplicate header banners and removed third-party credits (`osm0sis`) from `update-binary`.
- **System Model Branding**: Added `hakirfon` device model spoofing via Magisk module.

---

### 2. 🌐 Networking, BBR & Packet Injection Enhancements
- **TTL / HL Mangling Enabled (`CONFIG_NETFILTER_XT_TARGET_HL=y`, `CONFIG_IP6_NF_TARGET_HL=y`)**: Full tethering restriction bypass for mobile carriers directly from Android.
- **Google BBR TCP Congestion Control (`CONFIG_TCP_CONG_BBR=y`, `CONFIG_DEFAULT_BBR=y`)**: BBR enabled as the default TCP algorithm for maximum throughput and ultra-low latency in WireGuard tunnels.
- **Promiscuous Mode & Raw Packet Sniffing**: Enhanced packet socket subsystem (`CONFIG_PACKET=y`, `CONFIG_NET_RAW=y`, `CONFIG_IFB=y`) for Wireshark, Tshark, and Tcpdump.
- **NFQUEUE Raw Filtering (`CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y`)**: Intercept and alter traffic in userspace using Bettercap, Mitmproxy, and Scapy.

---

### 3. 🔌 Hardware Hacking, BadUSB & Power Management
- **USB OTG Power Switcher (`vst-otg`)**: New CLI tool to toggle Type-C power output on the fly:
  - `vst-otg 900` — Eco mode (default).
  - `vst-otg 1500` — 1.5A high-current mode for dual-antenna Alfa AWUS036ACH / HackRF One.
  - `vst-otg 2000` — 2.0A maximum current output.
- **USB Raw Gadget (`CONFIG_USB_RAW_GADGET=y`)**: Emulate arbitrary USB devices, FIDO2/U2F security keys, and perform low-level USB fuzzing.
- **DriveDroid / CD-ROM Mass Storage**: Boot PCs and install OS images via phone ISO storage.

---

### 4. ⚡ Memory, Filesystem & Anti-Knox Tuning
- **ZRAM with ZSTD Compression (`CONFIG_CRYPTO_ZSTD=y`, `CONFIG_ZRAM_DEF_COMP="zstd"`)**: Ultra-fast RAM compression freeing 2–3 GB memory for heavy Kali/Andrax chroot containers.
- **Samsung KNOX & DEFEX Fully Cleaned (`CONFIG_SECURITY_KNOX=n`)**: Zero background root-blocking daemon overhead.
- **F2FS Turbo**: Rapid garbage collection for faster wordlist parsing and database queries.
