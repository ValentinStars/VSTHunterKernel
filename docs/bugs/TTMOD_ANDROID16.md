# Сообщение разработчику TikTok-мода

Привет. Дополнение по native crash TTMod 46.8.3 (2024608030): Galaxy A51
SM-A515F, Evolution X 16 / SDK 36, ARM64, Magisk 30.7. Падение есть на
Alpha4 и Alpha5 ядре.

Первый запуск иногда падает через 2–3 секунды, повторный проходит. После
коротких успешных тестов снова есть tombstones 6 октября в 03:30 и 07:10:
AsyncTask #21, SIGSEGV / SEGV_MAPERR, PC=0.

libart BuildId: 8964cae12d6877ff90074f58eb578aa4.
libttmod BuildId: ca73343d3f818c2d7cff60fa663aad076f960208.
Исходный SHA-256 libttmod:
45ef87b1038007c9e5692d815500617837d48da17065431cc63a6d1289b5825b.

Стек: ClassLinker::SetupClass+264 → DefineClass+1284 →
FindClassInBaseDexClassLoader+1180 → FindClass+988.
Дизассемблирование именно этого libart уточнило вызов: SetupClass+264
вызывает через PLT mirror::Class::SetStatus(Handle<Class>, ClassStatus, Thread*):
_ZN3art6mirror5Class9SetStatusENS_6HandleIS1_EENS_11ClassStatusEPNS_6ThreadE.
x17 указывает в libttmod+0x8866c: wrapper SetClassStatus.
В тот же момент главный поток находится в libshadowhook.so+0x15258,
вызов __strlen. В дампе есть ещё не заполненные поля .bss.

Это повод проверить гонку публикации original/backup указателя и синхронизацию
LSPlant Init с параллельными потоками загрузки классов. Гонка пока гипотеза,
не окончательно доказанная причина.

Локальный обход двух optional visibility lookups по LSPlant issue #179 прошёл
пять холодных запусков и первый запуск после reboot, но длительный тест
подтвердил, что этого недостаточно. Версия мода не менялась; overlay виден
в root и zygote namespace. Одного skipping visibility hook для этого случая
недостаточно.

Можете проверить встроенные версии LSPlant/ShadowHook, обработку ошибки
hook_func_addr_2, публикацию original до первого вызова хука и совместимость
SetClassStatus / TrivialHandle с этим ART? Есть полные tombstones 20/21 для
приватной передачи; публично дампы с данными приложений не выкладываем.

## Исходники для проверки

- [LSPlant SetClassStatus / Init](https://github.com/LSPosed/LSPlant/blob/master/lsplant/src/main/jni/art/mirror/class.cxx)
- [Отдельная проблема optional visibility hook](https://github.com/LSPosed/LSPlant/issues/179)

Приведённые адреса получены из локального tombstone и дизассемблирования
точного libart этой прошивки. Гипотезы требуют проверки на исходниках мода.
