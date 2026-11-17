# Релиз в Google Play: instead-android-ng

## Артефакты

| Приложение | Пакет | Задача | Выход |
|---|---|---|---|
| Лаунчер | `com.nlbhub.instead.launcher` | `:launcher:bundleRelease` | `launcher/build/outputs/bundle/release/launcher-release.aab` |
| Red Hood (demo) | `com.nlbhub.instead.redhood` | `:games:redhood:bundleRelease` | `games/redhood/build/outputs/bundle/release/redhood-release.aab` |

Debug-варианты: `:launcher:assembleDebug`, `:games:redhood:assembleDebug`.

## Подпись

- В Play — **Play App Signing**. В репозиторий ключи не коммитятся.
- Локально/CI используется upload key из переменных окружения:
  `INSTEAD_KEYSTORE`, `INSTEAD_KEYSTORE_PASSWORD`, `INSTEAD_KEY_ALIAS`, `INSTEAD_KEY_PASSWORD`.
- По умолчанию (если переменные не заданы) используется `keystore/test-release.jks` — **только для локальных проверок**, в Play его загружать нельзя.

## Версии

Версии хранятся в `version.properties` и читаются сборочными скриптами; вручную
править `build.gradle.kts` не нужно. Выпуск — workflow `release` (см.
`docs/release.md`): он повышает версию, собирает AAB и создаёт черновик релиза.

- Лаунчер: `launcher.versionCode`, `launcher.versionName`.
- Red Hood: `redhood.versionCode`, `redhood.versionName`.

## Разрешения и объяснение для Play

| Разрешение | Зачем |
|---|---|
| `INTERNET` | загрузка каталога игр и игровых архивов |
| `ACCESS_NETWORK_STATE` | проверка сети перед загрузкой |
| `WAKE_LOCK` | экран не гаснет во время игры |

`READ/WRITE_EXTERNAL_STORAGE`, `MANAGE_EXTERNAL_STORAGE`, `CHECK_LICENSE`, `INSTALL_SHORTCUT`, `ACCESS_WIFI_STATE` удалены. Данные пишутся только в app-specific каталоги (`getExternalFilesDir()/…`, `getDir()`).

## Data safety (черновик)

- Персональные данные не собираются и не передаются.
- Приложение загружает каталог и игровые архивы по HTTPS с `instead-games.ru` / `nlbproject.com`; передаются только стандартные HTTP-заголовки, без идентификаторов пользователя.
- Шифрование в транзите: да (HTTPS, cleartext запрещён `network_security_config`).
- Удаление данных: пользователь удаляет приложение — данные в app-specific storage удаляются системой.
- Политика конфиденциальности обязательна (текст — `PRIVACY.md`, опубликовать на публичном URL и указать в Play Console и в приложении).

## Контент и рейтинг

- IARC-опросник: игра/каталог игр, без рекламы, без покупок, без UGC-загрузки пользователями (каталог редактируется разработчиком).
- Игры из каталога — сторонний контент; возрастной рейтинг выставляется по максимальному рейтингу каталога.
- Целевая аудитория: 12+/13+ (не «для детей»), если контент каталога это позволяет.

## Проверка 16 KB и 64-bit

```bash
# ELF-выравнивание в AAB (arm64-v8a, x86_64 — 0x4000)
llvm-readelf -l base/lib/arm64-v8a/libmain.so | grep LOAD
# 32-битный armeabi-v7a ожидаемо 0x1000 и не входит в требование 16 KB
```

Сборка использует NDK 28.2, поэтому выравнивание 16 KB включено по умолчанию; release-библиотеки стрипятся на этапе линковки (`-Wl,-s`), потому что AGP 8.13 не находит ABI-специфичный `strip` в NDK 28.

## Чек-лист перед загрузкой

- [ ] `targetSdk 36`, `minSdk 21`, `versionCode` больше предыдущего
- [ ] AAB собран с upload key (не с `test-release.jks`)
- [ ] Play App Signing включён, ключ загружен
- [ ] Data safety заполнена, политика конфиденциальности доступна по URL
- [ ] Content rating и target audience заполнены
- [ ] Внутренний трек → закрытый → продакшн
- [ ] 16 KB: `llvm-readelf` показывает `0x4000` для arm64-v8a
- [ ] В release-манифесте нет debug-export `STEADActivity`
- [ ] Проверены обновление с прошлой версии и сохранения

## Известные ограничения

- Игровое поле масштабируется с чёрной областью снизу (тема 576×1024 против 1080×2400) — косметика, не блокирует релиз.
- `libc++_shared.so` пакуется нестрипленным (~9 МБ на ABI) — можно уменьшить отдельной задачей.
- В `games/redhood` сейчас tutorial как заглушка; перед публикацией подложить реальный контент.
