# Ориентация экрана в играх

## Как выбирается ориентация

INSTEAD определяет её по теме игры (`themes.c`, `game_theme_init`):

- `theme.w > theme.h` → `rotate_landscape()`;
- `theme.w < theme.h` → `rotate_portrait()`;
- равны → `unlock_rotation()`.

На Android эти функции реализованы в `modules/instead_standalone/jni/src/instead_launcher.c`
и вызывают статические методы `STEADActivity.rotateLandscape/rotatePortrait/unlockRotation`
(`setRequestedOrientation`).

## Почему были чёрные поля

SDL при создании окна сам выставляет ориентацию активности по
`SDL_HINT_ORIENTATIONS` (`SDL_androidwindow.c`). Если hint не задан, SDL выбирает
`SCREEN_ORIENTATION_FULL_USER` — окно остаётся в текущей (портретной) ориентации,
а игра масштабируется с большими полями.

Вызов `rotate_*` происходил до создания SDL-окна, поэтому SDL затем перезаписывал
ориентацию на `FULL_USER`.

## Исправление

`rotate_*` теперь additionally задают hint перед созданием окна:

| Функция | `SDL_HINT_ORIENTATIONS` | Итоговая ориентация |
|---|---|---|
| `rotate_landscape` | `LandscapeLeft LandscapeRight` | `SENSOR_LANDSCAPE` |
| `rotate_portrait` | `Portrait` | `PORTRAIT` |
| `unlock_rotation` | все четыре | `FULL_USER` |

Игра фиксируется в ориентации своей темы; свободное вращение портрет↔ландшафт
запрещено, в ландшафте допускается переворот на 180°.

## Остаточные поля

Если соотношение сторон игры (например, 800×600, 4:3) не совпадает с экраном
(20:9), SDL вписывает кадр целиком и оставляет поля по краям. Это уже не ошибка
ориентации, а масштабирование: при желании можно добавить режим «растянуть/заполнить»
в настройках.
