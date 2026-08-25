# 📡 VSTHunterKernel Hardware Compatibility Matrix

## 1. 📶 Wi-Fi Adapters (Monitor Mode & Packet Injection)

| Chipset | Example Adapters | Driver | 2.4 GHz | 5 GHz | Packet Injection |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **RTL8812AU** | Alfa AWUS036ACH, TP-Link Archer T4U v1/v2 | `rtw88_8812au` | ✅ | ✅ | ✅ |
| **RTL8814AU** | Alfa AWUS1900 | `rtw88_8814au` | ✅ | ✅ | ✅ |
| **RTL8821AU** | Panda Wireless PAU0B | `rtw88_8821au` | ✅ | ✅ | ✅ |
| **RTL8822BU** | Edimax EW-7822ULC | `rtw88_8822bu` | ✅ | ✅ | ✅ |
| **AR9271** | TP-Link TL-WN722N v1, Alfa AWUS036NHA | `ath9k_htc` | ✅ | ❌ | ✅ |
| **AR9170** | D-Link DWA-160, Netgear WNDA3100 v1 | `carl9170` | ✅ | ✅ | ✅ |
| **RT3070** | Alfa AWUS036NEH, TP-Link TL-WN321G | `rt2800usb` | ✅ | ❌ | ✅ |
| **RT3572** | Alfa AWUS051NH v2 | `rt2800usb` | ✅ | ✅ | ✅ |
| **RTL8187L** | Alfa AWUS036H | `rtl8187` | ✅ | ❌ | ✅ |
| **RTL8188EUS** | TP-Link TL-WN722N v2/v3 | `rtl8xxxu` | ✅ | ❌ | ✅ |
| **MT7601U** | Xiaomi Mi Wi-Fi Dongle | `mt7601u` | ✅ | ❌ | ✅ |

---

## 2. 📻 SDR (Software Defined Radio)

| Device | Frequency Range | Driver | Applications |
| :--- | :--- | :--- | :--- |
| **RTL-SDR (RTL2832U)** | 24 MHz – 1.7 GHz | `rtl28xxu` / `dvb_usb_v2` | GQRX, SDR++, RTL-SDR CLI, ADS-B |
| **HackRF One** | 1 MHz – 6 GHz | `hackrf` | Full-duplex RX/TX, GNU Radio, RFCat |
| **AirSpy R2 / Mini** | 24 MHz – 1.8 GHz | `airspy` | High dynamic range VHF/UHF monitoring |
| **SDRplay / MSI2500** | 10 kHz – 2 GHz | `msi2500` | Wideband HF/VHF/UHF reception |

---

## 3. 🔌 Hardware Hacking & Automotive

| Device / Interface | Driver | Features |
| :--- | :--- | :--- |
| **Flipper Zero** | `cdc-acm` | Serial CLI, BadUSB, Sub-GHz dump, NFC |
| **Proxmark3 RDV4** | `cdc-acm` / `ftdi_sio` | RFID / HF / LF analysis, cloning |
| **ChameleonTiny** | `cdc-acm` | High frequency 13.56MHz RFID emulation |
| **FTDI / CP210x / CH341** | `usbserial` | Hardware UART debug, MCU flashing |
| **SocketCAN / SLCAN** | `slcan` / `can_raw` | OBD-II car sniffing, CAN injection |
