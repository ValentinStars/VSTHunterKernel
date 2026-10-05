# Сообщение разработчику TikTok-мода

Привет. Нашёл воспроизводимый native crash вашей версии TikTok-мода 46.8.3
(versionCode 2024608030) на Samsung Galaxy A51 SM-A515F / Exynos 9611.
ROM: Evolution X 16.0, Android 16 / SDK 36, Magisk 30.7.
Ядро: 4.14.364-NetHunter-VST-Alpha5; падение также было на Alpha4.

Симптом: первый запуск часто падает через 2–3 секунды, повторный иногда проходит.
Падает AsyncTask #22–25: SIGSEGV / SEGV_MAPERR, PC=0.
Свежий стек:

```text
#00 pc 0 <unknown>
#01 art::ClassLinker::SetupClass(...)+264
#02 art::ClassLinker::DefineClass(...)+1284
#03 art::ClassLinker::FindClassInBaseDexClassLoader(...)+1180
#04 art::ClassLinker::FindClass(...)+988
```

libart.so BuildId: `8964cae12d6877ff90074f58eb578aa4`.
В tombstone регистр x17 указывает в `libttmod.so` (offset 0x8866c), а не в
случайную область; библиотека содержит LSPlant/ShadowHook.
SHA256 libttmod.so:
`45ef87b1038007c9e5692d815500617837d48da17065431cc63a6d1289b5825b`.

Очень похоже на известную проблему optional ClassLinker visibility hooks на
Android 16: https://github.com/LSPosed/LSPlant/issues/179.
В LSPlant эти два lookup находятся в необязательной ветке инициализации:

```text
_ZN3art11ClassLinker26VisiblyInitializedCallback29AdjustThreadVisibilityCounterEPNS_6ThreadEl
_ZN3art11ClassLinker26VisiblyInitializedCallback22MarkVisiblyInitializedEPNS_6ThreadE
```

Для проверки локально отключил только разрешение этих двух символов в точной
копии библиотеки, не меняя libart.so и APK. После этого прошли пять запусков с
полной остановкой процесса без новых SIGSEGV; после перезагрузки первый запуск
тоже прошёл. Длительный тест ещё нужен.

Можете проверить SDK 36-guard для этой optional ветки и совместимость вашей
встроенной версии LSPlant с текущим ART? Похоже, её стоит пропускать на API 36,
как описано в issue, либо исправить совместимость хука. У меня есть полный
свежий tombstone для приватной передачи; в публичный issue полный дамп не
прикладываю, поскольку в нём есть информация об устройстве/приложениях.
