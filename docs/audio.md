# Трекерная музыка (MOD/S3M/XM/IT)

INSTEAD-игры могут использовать трекерную музыку: `.s3m`, `.xm`, `.it`, `.mod`.
Пример — `ilines`: фоновая музыка `snd/satellite.s3m`.

## Что включено

В SDL2_mixer 2.8 поддержка MOD вынесена в отдельный загрузчик на базе
**libxmp-lite** и по умолчанию выключена. В проекте:

- исходники libxmp 4.6.1-SDL лежат в
  `modules/instead_standalone/jni/SDL2_mixer/external/libxmp` (MIT);
- в `jni/Application.mk` включено:

  ```make
  SUPPORT_MOD_XMP := true
  ```

  и модуль `xmp` добавлен в `APP_MODULES`.

SDL2_mixer собирается с `-DMUSIC_MOD_XMP`, поэтому `Mix_LoadMUS` понимает
`.s3m/.xm/.it/.mod` и играет их через программный микшер.

## Проверка

```bash
adb logcat | grep -i "MUSIC\|s3m\|xmp"
```

При успешной загрузке в логе появляется `MUSIC OK snd/satellite.s3m`;
при ошибке — `MUSIC ERROR ...: <текст Mix_GetError>`.

Если музыка не играет, но загружается, проверять нужно микшер и аудиовыход
(например, эмулятор запущен с `-no-audio`), а не поддержку формата.
