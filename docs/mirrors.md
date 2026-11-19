# Зеркала каталогов игр

## Игры сообщества INSTEAD

Раздел «репозиторий игр» (Каталог и Песочница). Пока одно зеркало:

| Раздел | URL |
|---|---|
| Каталог | `https://www.instead-games.ru/xml.php` |
| Песочница | `https://www.instead-games.ru/xml2.php` |

## Non-Linear Text Quests

Разделы NLB project и Community. Два зеркала:

| Зеркало | Роль |
|---|---|
| `https://nlbhub.com` | по умолчанию |
| `https://nlbproject.com` | альтернативное |

| Раздел | URL |
|---|---|
| NLB project | `<зеркало>/hub/services/nlbproject_games` |
| Community | `<зеркало>/hub/services/community_games` |

## Настройка

Settings содержит два выпадающих списка:

- **INSTEAD community games mirror** — `www.instead-games.ru` (пока один вариант);
- **Non-Linear Text Quests mirror** — `nlbhub.com` (по умолчанию) или `nlbproject.com`.

Выбор сохраняется в SharedPreferences (`insteadGamesMirror`, `nlbMirror`) и
применяется к:

- URL загрузки каталогов;
- ссылкам на игровые архивы (`url` в XML);
- ссылкам на страницы описания (`descurl` в XML).

`DownloadMirrors` переписывает только «свои» домены:

- для INSTEAD — `instead-games.ru` / `www.instead-games.ru`;
- для NLTQ — `nlbhub.com` / `nlbproject.com` (включая `www.`).

Остальные домены не меняются.

## Конфигурация

`modules/instead_standalone/res/raw/config.properties` содержит URL как fallback.
`PropertyManager` всегда подставляет выбранные зеркала поверх значений файла,
поэтому старые `config.properties` в appdata менять не нужно.
