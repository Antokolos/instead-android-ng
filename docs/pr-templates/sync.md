# PR 1: bidirectional repository mirroring

**Base:** `master` ← **compare:** `sync-workflow`

## Что делает

Добавляет автоматическое зеркалирование между `Antokolos/instead-android-ng` и
`instead-hub/instead-android-ng`:

- `.github/workflows/mirror.yml` — запуск на любой push (ветки, теги) и вручную;
- `scripts/mirror-refs.sh` — синхронизация refs;
- `docs/mirroring.md` — настройка токенов/App, защита веток, разрешение конфликтов.

## Поведение

- ветка есть только локально → создаётся у партнёра;
- партнёр отстаёт → fast-forward push;
- партнёр впереди → пропуск (его workflow отправит изменения обратно);
- истории разошлись → ошибка, ничего не перезаписывается.

Никакого force-push: одновременный merge PR в обоих репозиториях не теряет коммиты.
PR-объекты не копируются — зеркалируются коммиты, ветки и теги.

## Перед merge

В репозитории, где будет merge, должен быть настроен один из вариантов:

1. GitHub App: секреты `APP_ID` и `APP_PRIVATE_KEY` (приложение установлено на
   оба владельца, доступ к `instead-android-ng`);
2. PAT: секрет `MIRROR_TOKEN` = токен **владельца парного репозитория**
   (для `instead-hub` это токен с resource owner `Antokolos`).

Иначе workflow упадёт на авторизации — код при этом смержится, а mirror можно
перезапустить кнопкой `Run workflow` после настройки секрета.

## Тест-план

1. Merge этого PR в `instead-hub/instead-android-ng`.
2. Actions → `mirror` → убедиться, что job зелёный.
3. Проверить, что в `Antokolos/instead-android-ng` появился/обновился `master`
   с merge-коммитом.
4. Сделать тестовый push ветки/тега в любой репозиторий и увидеть его во втором.
5. Проверить расхождение: закоммитить в оба `master` без синхронизации —
   workflow должен упасть с `Branch 'master' has diverged`.
