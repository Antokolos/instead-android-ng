# Зеркала каталогов игр

## NLB project games

| Зеркало | Роль |
|---|---|
| `https://nlbhub.com` | по умолчанию |
| `https://nlbproject.com` | альтернативное |

Каталог: `<зеркало>/hub/services/nlbproject_games`.

## Community games

Пока одно зеркало: `https://nlbproject.com`.
Каталог: `https://nlbproject.com/hub/services/community_games`.

## Настройка

Settings → **NLB project games mirror** / **Community games mirror**.
Выбор сохраняется в SharedPreferences (`nlbMirror`, `communityMirror`) и
применяется к:

- URL загрузки каталога;
- ссылкам на игровые архивы (`url` в XML);
- ссылкам на страницы описания (`descurl` в XML).

Ссылки на другие домены (например, `instead-games.ru`) не переписываются.

## Конфигурация

`modules/instead_standalone/res/raw/config.properties` содержит URL как fallback,
но `PropertyManager` всегда подставляет выбранное зеркало поверх значений файла.
Старые `config.properties` в appdata на устройстве переопределяются так же —
миграция не требуется.
