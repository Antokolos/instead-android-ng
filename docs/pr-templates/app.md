# PR 2: modernization for Google Play 2026

**Base:** `master` ← **compare:** `modernization-app`

## Что меняется

Перевод проекта с Ant/ADT на Gradle и соответствие требованиям Google Play 2026:

- **Сборка:** Gradle 8.13 + AGP 8.13.2, JDK 17, модули `:engine`, `:launcher`,
  `:games:redhood`; манифесты без `package`/`uses-sdk`;
- **SDK:** `compileSdk/targetSdk 36`, `minSdk 21` (было 13 — ниже 21 невозможно
  одновременно с 16 KB и поддерживаемым NDK);
- **Native:** NDK 28.2, `c++_shared`, `APP_PLATFORM=android-21`, ABI
  arm64-v8a/armeabi-v7a/x86_64, 16 KB-выравнивание (`LOAD 0x4000`);
- **Библиотеки:** SDL2 2.0.5 → 2.32.10, SDL2_image/mixer/ttf → 2.8.1/2.8.1/2.22.0,
  LuaJIT 2.1-beta3 → PUC Lua 5.1.5, INSTEAD 3.5.2 (закреплён по SHA-256);
- **Упаковка:** `.so` только в `jniLibs`; удалена распаковка библиотек из `res/raw`
  (нарушала W^X и 16 KB);
- **Google Play:** AAB, release с R8 и подписью из env, `INTERNET`/`ACCESS_NETWORK_STATE`/`WAKE_LOCK`,
  `appCategory="game"`, HTTPS-only, edge-to-edge, predictive back;
- **LVL/OBB:** удалены модули и весь код expansion/downloader;
- **Самостоятельные игры:** модуль `games/redhood` с контентом в assets,
  `BundledGameInstaller`, `StandaloneActivity`, `-standalone`;
- **Экран:** тема mobile адаптирована под 20:9 (нет чёрных полос);
- **Автоматизация:** `:engine:fetchInsteadSource` (SHA-256), GitHub Actions
  собирает оба AAB и проверяет 16 KB; `docs/play-release.md`, `PRIVACY.md`.

## Проверено

- `:launcher:assembleDebug` и `:games:redhood:assembleDebug` собираются;
- на эмуляторе Android 15 запускаются лаунчер, туториал INSTEAD и standalone-игра;
- release-AAB: 18,6 МБ (лаунчер), 19,4 МБ (игра), `targetSdk 36`, три разрешения,
  `Align 0x4000` для arm64-v8a/x86_64;
- release-APK устанавливаются и запускаются.

## Ломающие изменения

- `minSdk` 13 → 21 (≈0,2% устройств);
- LuaJIT заменён на PUC Lua (медленнее, зато нет host-сборки и JIT-страниц);
- OBB больше не поддерживается — контент самостоятельных игр в assets;
- INSTEAD обновлён до 3.5.2.

## Осталось

- подложить реальный контент Red Hood вместо tutorial;
- загрузить AAB в Play Console с реальным upload key;
- уменьшить нестрипленный `libc++_shared.so` (по желанию).
