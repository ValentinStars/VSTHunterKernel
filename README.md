# ⚡ VSTHunterKernel (VSTnh) — Custom NetHunter Kernel for Samsung Galaxy A51 (universal9611)

<p align="center">
  <img src="https://img.shields.io/badge/Kernel-Linux%204.14.364--NetHunter--VST--Alpha2-blue?style=for-the-badge&logo=linux" alt="Kernel Version"/>
  <img src="https://img.shields.io/badge/Android-13%20%7C%2014%20%7C%2015%20%7C%2016-green?style=for-the-badge&logo=android" alt="Android Support"/>
  <img src="https://img.shields.io/badge/Device-Samsung%20Galaxy%20A51%20(SM--A515F)-red?style=for-the-badge&logo=samsung" alt="Device"/>
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

**VSTHunterKernel (VSTnh)** is a high-performance, modular custom Linux kernel engineered for the **Samsung Galaxy A51 (SM-A515F / universal9611)** running modern AOSP ROMs (**Android 13, 14, 15, and 16 Evolution X**).

Designed from the ground up for **Kali NetHunter, Andrax, Wireless Security Auditing, SDR Radio Monitoring, BadUSB Attacks, and Hardware Hacking**, while maintaining 100% daily-driver stability, battery efficiency, and gaming performance.

---

## 🚀 Key Features

### 📡 1. Wireless Pentest & Frame Injection (`mac80211` / `cfg80211`)
- **Full Packet Injection & Monitor Mode** support on external USB Wi-Fi dongles.
- **Realtek `rtw88` Driver Stack**: Dual-band AC adapters (**RTL8812AU, RTL8814AU, RTL8821AU, RTL8822BU/CU**).
- **Realtek `rtl8xxxu` & `rtl818x`**: Alfa AWUS036H (RTL8187), TL-WN722N v2/v3 (RTL8188EUS/RTL8192EU).
- **Qualcomm Atheros**: TP-Link TL-WN722N v1 (`ath9k_htc`), `carl9170`, `ath6kl`, `ath10k`.
- **Ralink**: RT3070, RT3572, RT5370 (`rt2800usb`, `rt2500usb`).
- **MediaTek / Zydas**: `mt7601u`, `zd1211rw`.
- Built-in `vst-wifi` CLI tool for instant monitor mode switching and txpower adjustment.

### 🌐 2. In-Kernel WireGuard & Networking Stack
- **Native WireGuard in Kernel (`CONFIG_WIREGUARD=y`)**: Full ARM64 NEON assembly acceleration (`chacha20-arm64`, `poly1305-arm64`, `curve25519`, `blake2s`).
- **Google BBR TCP Congestion Control (`CONFIG_TCP_CONG_BBR=y`)**: Reduced latency and boosted throughput over cellular, Wi-Fi, and VPN.
- **TTL / HL Mangling (`CONFIG_NETFILTER_XT_TARGET_HL=y`, `CONFIG_IP6_NF_TARGET_HL=y`)**: Bypass mobile carrier tethering restrictions directly on Android (`iptables -t mangle -A POSTROUTING -j TTL --ttl-set 64`).
- **Promiscuous Mode & Raw Sockets**: Seamless packet capture in Wireshark, Tshark, and Tcpdump.
- **NFQUEUE Filtering (`CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y`)**: Intercept and alter traffic in userspace via Bettercap, Mitmproxy, Scapy.

### ⚡ 3. USB Gadget, BadUSB & Hardware Hacking
- **ConfigFS HID Arsenal**: Unlocked `/dev/hidg0` (keyboard) and `/dev/hidg1` (mouse) with 0666 permissions.
- **Rucky & Duckyscript Support**: Plug-and-play BadUSB keyboard injection.
- **USB Raw Gadget (`CONFIG_USB_RAW_GADGET=y`)**: Emulate arbitrary USB devices, FIDO2/U2F security keys, and perform low-level USB fuzzing.
- **DriveDroid CD-ROM / Mass Storage**: Boot PCs and install OS images directly from phone ISO storage.
- **USB CDC ACM (`CONFIG_USB_ACM=y`)**: Native direct connection to **Flipper Zero, Proxmark3 RDV4, ChameleonTiny, Arduino, STM32**.
- **USB Serial Drivers**: CP210x, FTDI, CH341, PL2303.
- **SocketCAN & CAN-Bus**: Automotive CAN auditing with `slcan.ko` and virtual CAN (`vcan`).

### 📻 4. SDR (Software Defined Radio)
- **RTL-SDR**: Realtek RTL2832U DVB-T dongles with R820T/R820T2, E4000, FC0012/13 tuners (GQRX, SDR++, RTL-SDR CLI).
- **HackRF One**: Direct wideband transceiver control (1 MHz – 6 GHz).
- **AirSpy & MSI2500**: High dynamic range SDR receivers.
- **USB OTG Power Switcher (`vst-otg`)**: Toggle OTG current limit between 900mA (eco), 1.5A, and 2.0A for high-draw SDR/Alfa hardware.

### 🏎️ 5. Performance, Memory & System Tuning
- **ZRAM with ZSTD Compression**: Ultra-fast RAM compression freeing 2–3 GB memory for heavy chroot containers (Kali NetHunter / Andrax).
- **F2FS Turbo**: Optimized flush timings for fast database and dictionary operations.
- **Samsung KNOX & DEFEX Completely Disabled**: Zero background root-blocking daemon overhead.
- **hakirfon Branding**: System model spoofing to `hakirfon (SM-A515F)`.

---

## 📦 Downloads & Installation

### Option 1: Live Flashing via SmartPack Kernel Manager (Recommended)
1. Open **SmartPack Kernel Manager** (grant Root permissions).
2. Go to **Flasher** -> Select `VSTHunterKernel-A51-NetHunter-VST-Alpha2.zip`.
3. Choose **Boot / Kernel** and tap **Flash**.
4. Reboot!

### Option 2: Recovery (TWRP / PBRP / OrangeFox)
1. Boot into Recovery.
2. Tap **Install** -> Select `VSTHunterKernel-A51-NetHunter-VST-Alpha2.zip`.
3. Swipe to Flash (No wipe required).
4. Reboot System.

---

## 🧩 Modular Magisk Packages

Install standalone modular extensions directly in Magisk:

| Module | Description |
| :--- | :--- |
| **`01_VST_BadUSB_NetHunter_Arsenal.zip`** | Auto-unlocks `/dev/hidg*` permissions + `vst-badusb` CLI. |
| **`02_VST_WireGuard_Toolkit.zip`** | Enables kernel IP forwarding, BBR TCP + `vst-wg` helper. |
| **`03_VST_Wireless_Pentest_Arsenal.zip`** | Firmware files in `/system/etc/firmware/` + `vst-wifi` monitor tool. |
| **`04_VST_SDR_Radio_Hacker.zip`** | SDR USB node permissions + `vst-sdr` device analyzer. |
| **`05_VST_Hardware_Hacking_CAN.zip`** | CDC-ACM permissions (Flipper/Proxmark) + `slcan.ko` + `vst-can`. |
| **`06_VST_hakirfon_Edition_SystemProp.zip`** | System model spoofing to `hakirfon` + performance flags. |
| **`07_VST_USB_OTG_Power_Switcher.zip`** | `vst-otg` CLI utility (900mA / 1500mA / 2000mA). |

---

## 🛠️ How to Build from Source

### Prerequisites (Ubuntu / Debian / Arch Linux):
```bash
sudo apt update && sudo apt install -y git make bc bison flex libssl-dev libelf-dev zip curl tar
```

### 1-Click Automated Build:
```bash
git clone https://github.com/ValentinStars/VSTHunterKernel.git
cd VSTHunterKernel
./build_kernel.sh
```

The script will automatically download the **Neutron Clang 18** toolchain, prepare `vstnh_defconfig`, compile the kernel image and modules, and package the flashable AnyKernel3 zip into `out/`!

---

## 👨‍💻 Author & Community

* **Lead Developer**: **Valentin Stars** ([Telegram: @vstbio](https://vstbio.t.me))
* **Repository**: [GitHub / ValentinStars / VSTHunterKernel](https://github.com/ValentinStars/VSTHunterKernel)
* **License**: GNU General Public License v2.0 (GPL-2.0)
