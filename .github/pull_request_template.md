<!-- AUTO-DESCRIPTION -->

## Что меняется

<!-- 1–3 предложения: что именно и зачем -->

## Как проверено

- [ ] `./gradlew :launcher:assembleDebug :games:redhood:assembleDebug`
- [ ] CI `android` зелёный (AAB + debug APK)
- [ ] `bash scripts/verify-16kb.sh` для релизных изменений
- [ ] Проверено на устройстве/эмуляторе: лаунчер и standalone-игра

## Чек-лист

- [ ] `targetSdk`/`minSdk` не менялись без обоснования
- [ ] 16 KB-выравнивание не нарушено
- [ ] Обновлены `docs/`, `PRIVACY.md`, если нужно
- [ ] В диффе нет секретов и ключей
- [ ] Для новых standalone-игр есть контент в `assets/game/`

## Release notes

<!-- короткая строка для changelog -->
