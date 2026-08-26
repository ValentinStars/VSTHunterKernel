# ⚡ VSTHunterKernel (VSTnh) — Custom NetHunter Kernel for Samsung Galaxy A51 (universal9611)

<p align="center">
  <img src="https://img.shields.io/badge/Kernel-Linux%204.14.364--NetHunter--VST--Alpha3-blue?style=for-the-badge&logo=linux" alt="Kernel Version"/>
  <img src="https://img.shields.io/badge/Android-13%20%7C%2014%20%7C%2015%20%7C%2016-green?style=for-the-badge&logo=android" alt="Android Support"/>
  <img src="https://img.shields.io/badge/Target%20ROM-Evolution%20X%20%7C%20AOSP-orange?style=for-the-badge" alt="Target ROM"/>
  <img src="https://img.shields.io/badge/Author-Valentin%20Stars-purple?style=for-the-badge&logo=telegram" alt="Author"/>
</p>

```text
.-..-..---..---.                   
| .` || |- `| |'                   
`-'-'`---' `-'                    
                                   
.-. .-..-..-..-..-..---..---..---. 
| |=| || || || .` |`| |'| |- | |-< 
`-' `-''----'`-'-' `-' `---'`-'`-' 

         ⚡ Valentin Stars (vstbio.t.me) ⚡
```

---

## 🎯 Overview

**VSTHunterKernel (VSTnh)** is a high-performance, modular custom Linux kernel designed for **Samsung Galaxy A51 (SM-A515F / universal9611)** running modern AOSP ROMs (**Android 13, 14, 15, and 16 Evolution X**).

Engineered specifically for **Kali NetHunter, Andrax, wireless security auditing, SDR radio monitoring, BadUSB attacks, and hardware hacking**, while maintaining 100% daily-driver stability, battery efficiency, and gaming performance.

---

## 🚀 Key Features

### 📡 1. Wireless Pentest & Frame Injection (`mac80211` / `cfg80211`)
- **Dedicated Aircrack-ng RTL8812AU Stack**: In-kernel driver with built-in microcode/firmware, VHT frame injection, and unlimited TX power control for Alfa AWUS036ACH and Realtek 8812AU adapters.
- **In-Kernel Extra Firmware Auto-Loading (`CONFIG_EXTRA_FIRMWARE`)**: Automated kernel microcode loading for **RTL8822BU/CU, RTL8821CU/AU, RTL8814AU, RTL8723DU, ATH9K HTC (9271/7010), Carl9170, RT2800USB, MT7601U**.
- **Realtek `rtw88` Stack**: Standard upstream stack for other 88xx adapters.
- **Qualcomm Atheros**: TP-Link TL-WN722N v1 (`ath9k_htc`), `carl9170`, `ath6kl`, `ath10k`.
- **Ralink & MediaTek**: RT3070, RT3572, RT5370 (`rt2800usb`), `mt7601u`, `zd1211rw`.
- Built-in `vst-wifi` CLI tool for instant monitor mode switching and txpower adjustment.

### 🌐 2. In-Kernel WireGuard & Networking Stack
- **Native WireGuard in Kernel (`CONFIG_WIREGUARD=y`)**: Full ARM64 NEON assembly acceleration (`chacha20-arm64`, `poly1305-arm64`, `curve25519`, `blake2s`).
- **Google BBR TCP Congestion Control (`CONFIG_TCP_CONG_BBR=y`)**: Reduced latency and boosted throughput over cellular and VPN.
- **TTL / HL Mangling (`CONFIG_NETFILTER_XT_TARGET_HL=y`)**: Bypass mobile carrier tethering restrictions (`--ttl-set 64`).
- **Promiscuous Mode & Raw Sockets**: Seamless packet capture in Wireshark, Tshark, and Tcpdump.
- **NFQUEUE Filtering (`CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y`)**: Intercept and modify packets in userspace via Bettercap, Mitmproxy, Scapy.

### ⚡ 3. USB Gadget, BadUSB & Hardware Hacking
- **ConfigFS HID Arsenal**: Unlocked `/dev/hidg0` (keyboard) and `/dev/hidg1` (mouse) with 0666 permissions.
- **Rucky & Duckyscript Support**: Plug-and-play BadUSB keyboard injection.
- **USB Raw Gadget (`CONFIG_USB_RAW_GADGET=y`)**: Emulate arbitrary USB devices, FIDO2/U2F security keys, and perform USB fuzzing.
- **DriveDroid CD-ROM / Mass Storage**: Boot PCs and install OS directly from phone ISO images.
- **USB CDC ACM (`CONFIG_USB_ACM=y`)**: Native direct connection to **Flipper Zero, Proxmark3 RDV4, ChameleonTiny, Arduino, STM32**.
- **USB Serial Drivers**: CP210x, FTDI, CH341, PL2303.
- **SocketCAN & CAN-Bus**: Automotive CAN auditing with `slcan.ko` and virtual CAN (`vcan`).

### 📻 4. SDR (Software Defined Radio)
- **RTL-SDR**: Realtek RTL2832U DVB-T dongles with R820T/R820T2, E4000, FC0012/13 tuners (GQRX, SDR++, RTL-SDR CLI).
- **HackRF One**: Direct wideband transceiver control.
- **AirSpy & MSI2500**: High dynamic range SDR receivers.
- **USB OTG Power Switcher (`vst-otg`)**: Toggle OTG current limit between 900mA, 1.5A, and 2.0A for high-draw SDR/Alfa hardware.

### 🏎️ 5. Performance, Memory & System Tuning
- **ZRAM with ZSTD Compression**: Ultra-fast RAM compression freeing 2–3 GB for heavy chroot containers (Kali/Andrax).
- **F2FS Turbo**: Optimized flush timings for fast database and dictionary operations.
- **Samsung KNOX / DEFEX Completely Disabled**: Zero background root-blocking daemon overhead.
- **hakirfon Branding**: System model spoofing to `hakirfon (SM-A515F)`.

---

## 📦 Download & Installation

### Option 1: Live Flashing via SmartPack Kernel Manager (No PC / Recovery needed)
1. Open **SmartPack Kernel Manager** (grant Root).
2. Go to **Flasher** -> Select `VSTHunterKernel-A51-NetHunter-VST-Alpha3.zip`.
3. Choose **Boot / Kernel** and tap **Flash**.
4. Reboot!

### Option 2: Recovery (TWRP / PBRP)
1. Boot into TWRP / OrangeFox / PBRP.
2. Tap **Install** -> Select `VSTHunterKernel-A51-NetHunter-VST-Alpha3.zip`.
3. Swipe to Flash (No wipe required).
4. Reboot System.

---

## 🧩 Magisk Modules Suite

Install standalone modular extensions directly in Magisk:

| Module | Description |
| :--- | :--- |
| **`00_VST_NetHunter_SD_AutoFix.zip`** | Vold fsck bypass + MicroSD NetHunter automount + CLI multi-suite. |
| **`01_VST_BadUSB_NetHunter_Arsenal.zip`** | Auto-unlocks `/dev/hidg*` permissions + `vst-badusb` CLI. |
| **`02_VST_WireGuard_Toolkit.zip`** | Enables kernel IP forwarding, BBR TCP + `vst-wg` helper. |
| **`03_VST_Wireless_Pentest_Arsenal.zip`** | Full wireless firmwares (RTL8812AU, rtw88, ATH9K) + `vst-wifi` CLI. |
| **`04_VST_SDR_Radio_Hacker.zip`** | SDR USB node permissions + `vst-sdr` device analyzer. |
| **`05_VST_Hardware_Hacking_CAN.zip`** | CDC-ACM permissions (Flipper/Proxmark) + `slcan.ko` + `vst-can`. |
| **`06_VST_hakirfon_Edition_SystemProp.zip`** | System model spoofing to `hakirfon` + performance flags. |
| **`07_VST_USB_OTG_Power_Switcher.zip`** | `vst-otg` CLI utility (900mA / 1500mA / 2000mA). |

---

## 🛠️ CLI Quick Reference

```bash
# BadUSB status check
su -c vst-badusb

# WireGuard kernel status
su -c vst-wg

# Put external Wi-Fi into Monitor Mode
su -c vst-wifi monitor wlan1

# Set Wi-Fi TX power to 30 dBm (1000mW)
su -c vst-wifi txpower wlan1 30

# Boost USB OTG power for Alfa / HackRF
su -c vst-otg 1500

# Check connected SDR hardware
su -c vst-sdr

# Bring up CAN-bus interface
su -c vst-can
```

---

## 👨‍💻 Author & Credits

* **Lead Developer**: **Valentin Stars** ([Telegram: @vstbio](https://vstbio.t.me))
* **Base Source**: Samsung Universal9611 OpenELA Linux 4.14
* **Toolchain**: Neutron Clang 18 LLVM Compiler
* **License**: GNU General Public License v2.0 (GPL-2.0)
