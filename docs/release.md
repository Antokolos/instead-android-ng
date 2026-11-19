# Выпуск релиза

Версия хранится в одном месте — `version.properties`:

```properties
launcher.versionCode=1090400
launcher.versionName=1.9.4
redhood.versionCode=105008
redhood.versionName=1.5.8
```

`launcher/build.gradle.kts` и `games/redhood/build.gradle.kts` читают её при сборке,
поэтому версия попадает в манифест автоматически и не дублируется в коде.

## Ручной выпуск

Actions → **release** → **Run workflow**:

- `component`: `launcher`, `redhood` или `both`;
- `bump`: `patch`, `minor` или `major`.

Workflow делает:

1. повышает версию в `version.properties`;
2. коммитит `chore: release ...` и пушит в `master` (коммит зеркалируется в второй
   репозиторий);
3. собирает AAB и debug APK с новой версией и переименовывает их:
   `instead-ng-1.9.4-launcher.aab`, `instead-ng-1.9.4-launcher-debug.apk`,
   `instead-ng-1.5.8-redhood.aab` и т.д.;
4. создаёт **черновик** релиза с этими ассетами, заголовком и черновыми заметками;
5. ждёт аппрува environment `release` — после него публикует черновик.

Пока job `Publish release` ждёт аппрува, черновик можно отредактировать в
GitHub → Releases: поправить заголовок и текст, проверить ассеты. Аппрув
публикует уже отредактированный текст.

## Правила версий

- **launcher**: `versionCode = major*1000000 + minor*10000 + patch*100`
  (1.8.0 → 1080000, 1.8.1 → 1080100, 1.9.0 → 1090000). Монотонно и с запасом.
- **redhood**: `versionCode = major*100000 + minor*1000 + patch`
  (1.5.8 → 105008, 1.5.9 → 105009, 1.6.0 → 106000).
- Теги: `v<launcher version>` для лаунчера, `redhood-v<game version>` для игры,
  для `both` — `v<launcher version>`.
- Повторный запуск с уже существующим тегом падает до сборки.

## Настройка (один раз)

1. **Environment для аппрува:** Settings → Environments → New environment `release`;
   включите **Required reviewers** и добавьте себя/мейнтейнера.
2. **Upload key для Play:** секреты репозитория:
   - `INSTEAD_KEYSTORE_BASE64` — `.jks` в base64 (`base64 -w0 keystore.jks`);
   - `INSTEAD_KEYSTORE_PASSWORD`, `INSTEAD_KEY_ALIAS`, `INSTEAD_KEY_PASSWORD`.
   Без `INSTEAD_KEYSTORE_BASE64` workflow подпишет артефакты временным ключом и
   предупредит, что они не подходят для Play.
3. **Push в master:** release-боту нужно право пушить в защищённую ветку — добавьте
   `github-actions`/бота в bypass list правил защиты или разрешите push в `master`.
   Если защита не позволяет, job `bump` упадёт до сборки.
4. **Права Actions:** Settings → Actions → General → Workflow permissions —
   **Read and write** (нужно для коммита и создания релиза).

## Локально

```powershell
# поднять patch-версию лаунчера
bash scripts/bump-version.sh launcher patch

# собрать и проверить, что версия подхватилась
.\gradlew.bat :launcher:assembleDebug
```

Скрипт печатает `previous`, `version`, `code` и пишет их в `$GITHUB_OUTPUT`, если
переменная задана.

## Зеркалирование

После bump-коммита и после публикации (создания тега) release-workflow сам запускает
workflow mirror, потому что события от GITHUB_TOKEN не порождают новых прогонов.
Дополнительно mirror работает по расписанию раз в 30 минут.
