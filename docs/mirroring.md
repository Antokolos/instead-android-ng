# Зеркалирование репозиториев

Два репозитория:

- `Antokolos/instead-android-ng` — основной;
- `instead-hub/instead-android-ng` — зеркало.

Изменения, отправленные в любой из них, автоматически попадают во второй.
PR-объекты GitHub не копируются: зеркалируются **коммиты, ветки и теги**, поэтому
PR, смёрженный в одном репозитории, появляется во втором как обычные коммиты в ветке.

## Как это работает

`.github/workflows/mirror.yml` запускается на `push` (ветки и теги) и по кнопке
`Run workflow`. Workflow:

1. забирает все ветки и теги своего репозитория;
2. забирает состояние второго репозитория;
3. для каждой ветки:
   - если ветка есть только локально — создаёт её у второго;
   - если второй отстаёт — делает fast-forward push;
   - если второй впереди — пропускает (его собственный workflow отправит изменения обратно);
   - если истории разошлись — падает с ошибкой, ничего не перезаписывая;
4. добавляет отсутствующие теги.

Принципиально **нет force-push**: зеркало никогда не затирает чужие коммиты.
Совпадающие refs не порождают новых push-событий, поэтому цикл A→B→A заканчивается
на первом круге.

## Настройка (один раз)

### Вариант A: GitHub App (рекомендуется, без PAT)

Токен не хранится и не запоминается: workflow получает установочный токен на парный
репозиторий на время запуска (живёт час).

1. GitHub → Settings → Developer settings → GitHub Apps → **New GitHub App**.
   Владелец — ваш пользователь; приложение можно установить и на пользователя,
   и на организацию.
2. Permissions → Repository permissions: **Contents: Read and write**,
   Metadata: Read-only.
3. Создайте приложение, запишите **App ID** и сгенерируйте **private key** (`.pem`).
4. Установите приложение на оба аккаунта, выбрав только репозиторий
   `instead-android-ng`: Install App → `Antokolos` → Only select repositories →
   `instead-android-ng`; затем то же для `instead-hub`.
5. В **обоих** репозиториях: Settings → Secrets and variables → Actions:
   - `APP_ID` — числовой App ID;
   - `APP_PRIVATE_KEY` — всё содержимое `.pem`, включая строки `BEGIN`/`END`.
6. Workflow сам определит режим: если `APP_ID` задан, используется App,
   иначе — PAT из `MIRROR_TOKEN`.

Приватный ключ приложения — единственный секрет, который нужно сохранить
(например, в менеджере паролей). Токены для push генерируются автоматически.

### Вариант B: два fine-grained PAT

Fine-grained PAT привязан к одному **resource owner**, поэтому один токен не может
покрыть и `Antokolos`, и `instead-hub`. Нужны два токена — по одному на владельца.

| Токен | Resource owner | Repository access | Permissions |
|---|---|---|---|
| **A** | `Antokolos` | `Antokolos/instead-android-ng` | Contents: Read and write; Metadata: read |
| **B** | `instead-hub` | `instead-hub/instead-android-ng` | Contents: Read and write; Metadata: read |

В каждом репозитории workflow пишет **в парный** репозиторий, поэтому секрет
`MIRROR_TOKEN` — это токен владельца парного репозитория:

| Репозиторий, где запускается workflow | Значение `MIRROR_TOKEN` |
|---|---|
| `Antokolos/instead-android-ng` (пишет в `instead-hub/...`) | **токен B** |
| `instead-hub/instead-android-ng` (пишет в `Antokolos/...`) | **токен A** |

Значение PAT GitHub показывает **один раз** при создании. Запоминать его не нужно:
сохраните в менеджере паролей и вставьте в GitHub Secrets. Секреты GitHub
write-only — прочитать их обратно нельзя, при утере токен перевыпускается.

### Вариант C: один classic PAT

Classic PAT привязан к пользователю, а не к владельцу репозитория. Если вы
collaborator с правом записи в обоих репозиториях, создайте classic token со
scope `repo` и положите его как `MIRROR_TOKEN` в оба репозитория. Минус — токен
даёт доступ ко всем вашим репозиториям, поэтому его нужно хранить и ротировать
аккуратнее.

### Защита веток

Если на `master`/`main` включена защита, разрешите push от владельца токена
(App или PAT): добавьте его в bypass list либо отключите
«Require a pull request before merging» для зеркалируемых веток.

### Первый запуск

Actions → mirror → Run workflow (или любой push). Если истории уже разошлись,
см. раздел ниже.

### Если токен не подходит

- `403 Resource not accessible by personal access token` — токен выдан на другого
  владельца или без прав `Contents: Read and write`.
- `401` — токен истёк или отозван.
- App: `404` при установке токена — приложение не установлено на нужного
  владельца или ему не выдан доступ к репозиторию.
- Проверка PAT: `curl -H "Authorization: Bearer <token>" https://api.github.com/repos/<owner>/<repo>`.
## Сценарии

| Действие | Результат |
|---|---|
| push в `modernization` в A | ветка появляется/обновляется в B |
| push тега `v1.9.0` в A | тег появляется в B |
| PR смёржен в `master` в A | merge-коммиты уходят в `master` B |
| PR смёржен в `master` в B | коммиты уходят в `master` A |
| push в B | зеркалируется в A |

## Расхождение истории

Если обе стороны получили коммиты, которых нет друг у друга (например, PR
смёржили одновременно), workflow завершится ошибкой:

```
::error::Branch 'master' has diverged between the repositories; merge it manually and push again
```

Что делать:

```bash
git fetch origin
git fetch https://github.com/<peer>.git master:peer-master
git merge peer-master        # или rebase, если так принято в проекте
git push origin master       # после этого mirror разошлёт merge во второй репозиторий
```

Ничего не потеряно: fast-forward-only гарантирует, что workflow не перезапишет
ветку. Не используйте force-push в зеркалируемые ветки — переписанная история
не зеркалируется.

## Ограничения

- Удаление ветки/тега не зеркалируется (это защита от случайной потери).
- Force-push и rewrite history не поддерживаются.
- PR, комментарии, review и issues не копируются — только git-история.
- Токен должен иметь доступ к обоим репозиториям; при его истечении workflow
  упадёт с ошибкой авторизации.
