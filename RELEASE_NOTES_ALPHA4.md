# ⚡ VSTHunterKernel v2.0-Alpha4 (GIGA Edition) Release Notes ⚡
**Target Device:** Samsung Galaxy A51 (SM-A515F / universal9611)  
**Author & Lead Dev:** Valentin Stars ([vstbio.t.me](https://vstbio.t.me))  
**Codebase Standard:** `#STOP_SHITCODING`  
**Branding:** `hakirfon GIGA Edition`  
**Architecture:** ARM64 (4x Cortex-A73 @ 2.3 GHz + 4x Cortex-A53 @ 1.7 GHz, Mali-G72 MP3)

---

## 🚀 Key Innovations & GIGA Alpha4 Features

### 1. 🛡️ Emergency Hardware Recovery Combo (Kernel-Level)
* **Feature:** Simultaneous 4-second hold of **Volume Up + Volume Down** hardware keys forces an emergency reboot directly into Recovery mode (`recovery`).
* **Implementation:** Built directly into the kernel's GPIO input driver (`drivers/input/keyboard/gpio_keys.c`).
* **Benefit:** Unbrick & recover anytime, even if the Android userspace / SystemUI / SurfaceFlinger completely freezes or enters a hard crash loop.

### 2. ⚡ Screen-On Ultra Fast Charging (2.1A / 2.4A)
* **Feature:** Samsung SIOP (Samsung Intelligent Overheat Protection) current throttling while the screen is ON has been unlocked from 1000/1200 mA to **2100 mA**.
* **Implementation:** Modified power boundaries in `drivers/battery_v2/include/sec_battery.h`.
* **Benefit:** Phone charges rapidly even while heavy pentest scripts, Kali Linux rootfs, or high-load tasks are running on-screen.

### 3. 🧠 Multi-Gen LRU (MGLRU) Memory Subsystem
* **Feature:** Enabled high-performance `CONFIG_LRU_GEN=y`, `CONFIG_LRU_GEN_ENABLED=y`, `CONFIG_LRU_GEN_STATS=y`.
* **Implementation:** Modern multi-generational LRU page reclamation in `mm/vmscan.c`.
* **Benefit:** Drastically reduces page-cache thrashing, eliminates UI stutters under heavy RAM pressure, and maximizes multitasking responsiveness.

### 4. 🎮 ARM Mali-G72 MP3 Frame Pacing (10ms Quantum)
* **Feature:** Reduced GPU job dispatch timeslice `DEFAULT_JS_CTX_TIMESLICE_NS` from 50 ms to **10 ms** (`10000000 ns`).
* **Implementation:** `drivers/gpu/arm/bv_r38p1/mali_kbase_config_defaults.h`.
* **Benefit:** Drastic reduction in micro-stutters and frame drops across Android UI and 3D rendering.

### 5. 🌙 Kernel Wakelock Blocker (Deep Sleep Maximizer)
* **Feature:** Silent rejection of notorious Samsung persistent wakelocks (`ssp_wake_lock`, `sec-battery-monitor`).
* **Implementation:** `kernel/power/wakelock.c`.
* **Benefit:** Prevents battery drain when screen is locked, ensuring deep sleep states.

### 6. 🐳 Docker, Waydroid & Advanced Networking
* **Feature:** Native Linux Bridge (`CONFIG_BRIDGE=y`, `CONFIG_BRIDGE_NETFILTER=m`), User Namespaces (`CONFIG_USER_NS=y`), and Fair Queueing Codel (`CONFIG_NET_SCH_FQ_CODEL=y`, `CONFIG_NET_SCH_FQ=y`, `CONFIG_NET_SCH_CODEL=y`).
* **Benefit:** Full compatibility with containerized Docker / Waydroid stacks, ultra-low latency TCP networking with BBR congestion control.

### 7. 🔐 Samsung SSS Hardware Crypto Engine
* **Feature:** Activated `CONFIG_CRYPTO_DEV_S5P=y` for hardware-accelerated AES / SHA / PRNG operations on Exynos 9611 silicon.

---

## 📦 Release Artifacts

1. **Kernel AnyKernel3 Flashable Zip:**
   * `VSTHunterKernel-A51-NetHunter-VST-Alpha4.zip`
2. **Magisk Modules Pack (v2.0-Alpha4):**
   * `00_VST_NetHunter_SD_AutoFix.zip` — MicroSD Vold fsck bypass & NetHunter CLI launchers
   * `01_VST_BadUSB_NetHunter_Arsenal.zip` — ConfigFS BadUSB & HID Rubber Ducky
   * `02_VST_WireGuard_Toolkit.zip` — Kernel WireGuard NEON VPN toolkit
   * `03_VST_Wireless_Pentest_Arsenal.zip` — Wi-Fi injection & packet manipulation suite
   * `04_VST_SDR_Radio_Hacker.zip` — RTL-SDR & HackRF radio toolchain
   * `05_VST_Hardware_Hacking_CAN.zip` — SocketCAN & hardware hacking bus tools
   * `06_VST_hakirfon_Edition_SystemProp.zip` — Hakirfon system properties & tuning
   * `07_VST_USB_OTG_Power_Switcher.zip` — OTG VBUS reverse-power control CLI (`vst-otg`)

---
*Built with Neutron Clang 18 LLVM/LLD toolchain. Standard: #STOP_SHITCODING.*
