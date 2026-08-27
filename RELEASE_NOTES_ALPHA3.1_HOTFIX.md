# ⚡ VSTHunterKernel (VSTnh) v2.0-Alpha3.1-Hotfix ⚡
### Custom Kali NetHunter & Pentest Kernel for Samsung Galaxy A51 (universal9611 / SM-A515F)
**Maintainer:** Valentin Stars ([vstbio.t.me](https://vstbio.t.me))  
**Branding Edition:** `hakirfon`

---

## 🚀 Hotfix & Major Improvements in Alpha3.1-Hotfix

### 1. 🛡️ Critical Android Bootloop Fix (SurfaceFlinger Conflict Resolution)
* **Устранена причина бутлупа:** Полностью отключены десктопные флаги `CONFIG_FRAMEBUFFER_CONSOLE=y`, `CONFIG_VT=y` и передача `console=tty0` в cmdline.
* **Результат:** Графический сервер Android (`SurfaceFlinger`) и драйвер дисплея Samsung DECON теперь корректно инициализируют видеобуфер без блокировок и конфликтов.
* **Краш-логи:** Для анализа паник сохранен аппаратный `CONFIG_SEC_DEBUG` и `pstore / ramoops` (`/proc/last_kmsg`).

### 2. ⚡ Universal Automated Build System (`vst_build.sh`)
* Создан умный bash-скрипт `vst_build.sh` для гибкой и быстрой компиляции:
  * Поддержка параметров: `./vst_build.sh --version Alpha3.1-Hotfix --modules`
  * Инкрементальный Kbuild (перекомпиляция только измененных файлов за ~10-20 секунд вместо 5 минут).
  * Автоматическое обновление `CONFIG_LOCALVERSION`, AnyKernel3 метаданных и Magisk-модулей.
  * Интеграция с `ccache` и GitHub CLI (`gh release`).

### 3. 📜 Манифест качества и архитектурный стандарт (`ARCHITECTURE_AND_STANDARDS.md`)
* Введен манифест **`#STOP_SHITCODING`**:
  * Четкое разграничение: **In-Kernel (`=y`)** (Wi-Fi инжекция, WireGuard NEON, BadUSB HID, F2FS/EROFS/IncFS) vs **Magisk-модули** (пользовательские CLI `vst-*`, firmware, брендинг).
  * Запрет на несовместимые с Android подсистемы в cmdline.

### 4. 📊 Плавный монитор компиляции (`smooth_monitor.py`)
* Реализован Python-скрипт с цветным терминальным интерфейсом и live progress bar для мониторинга сборки ядра.

### 5. 🧩 Полный набор Magisk-модулей v2.0-Alpha3.1-Hotfix (00–07)
* `00_VST_NetHunter_SD_AutoFix.zip` — авто-монтирование MicroSD ext4 rootfs.
* `01_VST_BadUSB_NetHunter_Arsenal.zip` — BadUSB HID инжекция.
* `02_VST_WireGuard_Toolkit.zip` — быстрый VPN toolkit.
* `03_VST_Wireless_Pentest_Arsenal.zip` — firmware для внешних адаптеров и утилита `vst-wifi`.
* `04_VST_SDR_Radio_Hacker.zip` — поддержка RTL-SDR / HackRF.
* `05_VST_Hardware_Hacking_CAN.zip` — модуль `slcan.ko` и SocketCAN.
* `06_VST_hakirfon_Edition_SystemProp.zip` — брендинг системы `hakirfon Alpha3.1-Hotfix`.
* `07_VST_USB_OTG_Power_Switcher.zip` — переключатель тока OTG (900mA / 1.5A–2.0A).

---

## 📥 Установка
1. Прошейте `VSTHunterKernel-A51-NetHunter-VST-Alpha3.1-Hotfix.zip` через TWRP / OrangeFox.
2. Установите необходимые Magisk-модули из пакета `00`–`07`.
3. Перезагрузите устройство.
