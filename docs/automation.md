# Автоматизация сборки

## INSTEAD-исходники

Задача `:engine:fetchInsteadSource` скачивает INSTEAD **3.5.2** с GitHub и проверяет SHA-256:

```
57d905983a5c55e65263a6a043f9c8a1c08fe0f7c4dd088bdbb739376121f113
```

- Если `modules/instead_standalone/jni/src/instead` уже существует (локальная разработка), задача ничего не скачивает, а только пишет маркер `.instead-version`.
- Скачивание и распаковка безопасны: проверяется контрольная сумма, zip-записи не могут выйти за пределы каталога.
- `prepareInsteadData` и `prepareGameContent` зависят от этой задачи, поэтому обычный `assembleDebug`/`bundleRelease` сам подтягивает движок.

Обновить версию INSTEAD: изменить `insteadVersion`, `insteadSha256` и `insteadZipUrl` в `modules/instead_standalone/build.gradle.kts`.

## CI

`.github/workflows/android.yml` на каждый push/PR:

1. ставит JDK 17, Android SDK 36 и NDK 28.2;
2. генерирует временный CI-keystore (только для сборки артефактов, не для Play);
3. собирает `launcher-release.aab` и `redhood-release.aab`;
4. проверяет 16 KB-выравнивание скриптом `scripts/verify-16kb.sh`;
5. выкладывает AAB в артефакты workflow.

Для реальной публикации используйте свой upload key из секретов:

```yaml
env:
  INSTEAD_KEYSTORE: ${{ secrets.INSTEAD_KEYSTORE_PATH }}
  INSTEAD_KEYSTORE_PASSWORD: ${{ secrets.INSTEAD_KEYSTORE_PASSWORD }}
  INSTEAD_KEY_ALIAS: ${{ secrets.INSTEAD_KEY_ALIAS }}
  INSTEAD_KEY_PASSWORD: ${{ secrets.INSTEAD_KEY_PASSWORD }}
```

`INSTEAD_KEYSTORE` — путь к `.jks` в workspace (в CI его нужно положить шагом `base64 -d` из секрета).

## Локальная проверка

```powershell
# Windows
.\gradlew.bat :launcher:bundleRelease :games:redhood:bundleRelease
bash scripts/verify-16kb.sh launcher/build/outputs/bundle/release/launcher-release.aab
```

На Windows без bash проверка: `llvm-readelf -l lib/arm64-v8a/libmain.so | findstr LOAD` — ожидается `0x4000`.
