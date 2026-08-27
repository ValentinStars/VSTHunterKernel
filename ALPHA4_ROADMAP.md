# 📋 VSTHunterKernel — Полная Дорожная Карта и Спецификация GIGA Alpha4

> **Целевая платформа:** Samsung Galaxy A51 (SM-A515F / universal9611)  
> **Базовое ядро:** Linux 4.14 ARM64 (Neutron Clang 18 LLVM/LLD)  
> **Стандарт разработки:** #STOP_SHITCODING  
> **Версия:** v2.0-Alpha4  

---

## 🎯 1. Утверждённый арсенал улучшений для GIGA Alpha4

### 💽 1. DriveDroid & LUN CD-ROM Patch
* **Файл:** `drivers/usb/gadget/function/f_mass_storage.c`
* **Что делаем:** Внедряем патч эмуляции SCSI оптического привода (`SCSI_TYPE_CDROM = 0x05`) и обработку SCSI-команд `READ_TOC` / `READ_HEADER`.
* **Результат:** Телефон определяется компьютером/сервером как физический USB-дисковод и позволяет загружать ПК с любых ISO-образов (Windows, Linux LiveCD, Hiren's BootCD).

### 🆘 2. Emergency Key Combo в ядре (Vol+ & Vol- -> Recovery)
* **Файл:** `drivers/input/keyboard/` (хук в обработчик клавиш)
* **Что делаем:** Аппаратный таймер в ядре: при одновременном зажатии `Vol+` и `Vol-` на 4 секунды ядро принудительно вызывает `kernel_restart("recovery")`.
* **Результат:** Гарантированное спасение и вход в Recovery даже при полном зависании графики или hard lockup Android без подключения к ПК.

### 🧠 3. Активация Multi-Gen LRU (MGLRU)
* **Файлы:** `mm/vmscan.c`, `mm/workingset.c`, `arch/arm64/configs/vstnh_defconfig`
* **Флаги:** `CONFIG_LRU_GEN=y`, `CONFIG_LRU_GEN_ENABLED=y`, `CONFIG_LRU_GEN_STATS=y`
* **Что делаем:** Код MGLRU уже портирован в дерево ядра. Активируем его в defconfig.
* **Результат:** Снижение нагрузки на процессор при нехватке памяти до 80%, удержание в 2–3 раза большего количества приложений в фоне без выгрузки.

### ⚡ 4. ZRAM ZSTD + Simple LMK (Sultanxda)
* **Файлы:** `mm/simple_lmk.c`, `drivers/block/zram/`
* **Флаги:** `CONFIG_ANDROID_SIMPLE_LMK=y`, `CONFIG_ZRAM_DEF_COMP_ZSTD=y`
* **Что делаем:** Внедряем легковесный внутриядерный киллер процессов `simple_lmk` от Sultanxda.
* **Результат:** Замена медленного юзерспейс-демона `lmkd`, мгновенное освобождение памяти без фризов UI.

### 🌐 5. Сетевой стек: CAKE Qdisc & TCP BBR
* **Файлы:** `net/sched/sch_cake.c`, `net/ipv4/tcp_bbr.c`
* **Флаги:** `CONFIG_NET_SCH_CAKE=y`, `CONFIG_TCP_CONG_BBR=y`, `CONFIG_DEFAULT_TCP_CONG="bbr"`
* **Что делаем:** Портируем планировщик очереди CAKE в `net/sched/` и включаем его в defconfig.
* **Результат:** Ликвидация эффекта Bufferbloat, минимальный пинг и стабильный трафик в Wi-Fi и мобильных сетях.

### 🐳 6. Waydroid, Docker & Контейнеризация
* **Флаги:** `CONFIG_BRIDGE=y`, `CONFIG_BRIDGE_NETFILTER=y`, `CONFIG_USER_NS=y`, `CONFIG_NAMESPACES=y`, `CONFIG_VETH=y`, `CONFIG_OVERLAY_FS=y`, `CONFIG_ANDROID_BINDERFS=y`
* **Что делаем:** Включаем мосты Ethernet, поддержку виртуальных сетей veth и User Namespaces.
* **Результат:** Нативный запуск контейнеров Docker, lxc, chroot и окружений Waydroid.

### 🔋 7. Screen-on Fast Charging (до 2.4А)
* **Файлы:** `drivers/battery_v2/` (`sec_battery.c`, `sec_charging_common.c`)
* **Что делаем:** Отключаем программный сброс тока Samsung до 1000 мА при активном экране.
* **Результат:** Быстрая зарядка телефона полным током 2100–2400 мА даже во время использования экрана (игры, видео, навигатор).
* *(Примечание: `vst-otg` остаётся для реверсивного питания внешних адаптеров с порта Type-C).*

### 💤 8. Exynos Wakelock Blocker (Рекордный Deep Sleep)
* **Файл:** `kernel/power/wakelock.c`
* **Что делаем:** Блокируем паразитные системные вейклоки `ssp_wake_lock` (Sensor Hub) и `sec-battery-monitor`.
* **Результат:** Разряд батареи в режиме сна падает до ~0.3–0.5% за ночь. Телефон может часами держаться на одном проценте.

### 🔌 9. Патч DWC3 USB под контроллер Samsung MUIC (SM5713 / S2MU004)
* **Файл:** `drivers/usb/dwc3/dwc3-exynos.c`
* **Что делаем:** Игнорируем ложные сбросы питания VBUS от контроллера разъёма MUIC при активации нестандартных USB дескрипторов.
* **Результат:** 100% стабильная работа BadUSB HID (`/dev/hidg0`) и DriveDroid CD-ROM без внезапных отвалов USB.

### 🎮 10. Оптимизация GPU ARM Mali-G72 MP3 (Exynos 9611)
* **Файлы:** `drivers/gpu/arm/bv_r38p1/` (kbase)
* **Что делаем:**
  * Уменьшаем квант времени планировщика заданий `DEFAULT_JS_CTX_TIMESLICE_NS` с 50 мс до **10 мс**.
  * Снижаем период замера нагрузки `utilisation_sample_period` со 100 мс до **35 мс** и порог переключения частот `high_threshold` до **75%**.
* **Результат:** Устранение микрофризов и просадок 1% Low FPS в играх и анимациях Android.

### 🔐 11. Samsung SSS Hardware Crypto Engine
* **Флаг:** `CONFIG_CRYPTO_DEV_S5P_SSS=y`
* **Что делаем:** Включаем в defconfig драйвер аппаратного криптопроцессора Samsung Security Subsystem (`drivers/crypto/s5p-sss.c`).
* **Результат:** Аппаратное ускорение симметричного шифрования AES/SHA в TrustZone/TEEGRIS.

### 🧰 12. Ramoops Persistent RAM (DTS адресация для Exynos 9611)
* **Файл:** `arch/arm64/boot/dts/exynos/universal9611.dtsi`
* **Что делаем:** Резервируем 1 МБ памяти по адресу `0x8ef00000` (`reg = <0x0 0x8ef00000 0x0 0x00100000>`).
* **Результат:** Полный дамп `dmesg` при сбое сохраняется в `/sys/fs/pstore/console-ramoops-0`.

---

## 🚫 2. Пункты, КАТЕГОРИЧЕСКИ ИСКЛЮЧЕННЫЕ из Alpha4

1. ❌ **KernelSU-Next + SuSFS** — **НЕ СТАВИМ**  
   * *Причина:* У пользователя установлен Magisk, ядро полностью настроено под Magisk.
2. ❌ **`CONFIG_KVM=y` (Виртуализация ARM KVM)** — **ЗАПРЕЩЕНО**  
   * *Причина:* Загрузчик Samsung S-Boot блокирует гипервизор EL2, вызовет Kernel Panic.
3. ❌ **Твики Mongoose M3/M4 (Exynos 9810/9820)** — **НЕПРИМЕНИМО К A51**  
   * *Причина:* На Galaxy A51 стоят ядра Cortex-A73 + Cortex-A53, ядер Mongoose физически нет.
4. ❌ **Qualcomm / Adreno / Cirrus Logic патчи** — **НЕПРИМЕНИМО К A51**  
   * *Причина:* На A51 установлены ARM Mali GPU и кодек Realtek RT5665 / Tas2562.
5. ❌ **`CONFIG_FRAMEBUFFER_CONSOLE` / `console=tty0`** — **ЗАПРЕЩЕНО**  
   * *Причина:* Вызывает конфликт с Android SurfaceFlinger и приводит к бутлупу.
