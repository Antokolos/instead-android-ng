APP_ABI := arm64-v8a armeabi-v7a
APP_PLATFORM := android-21
APP_STL := c++_shared
# Старые вендоренные C++-модули (libmodplug, smpeg2) используют register и
# сужающие инициализации: C++17/новый clang это запрещают.
APP_CPPFLAGS := -std=c++14 -Wno-c++11-narrowing
# Внешние кодеки, которых нет в дереве SDL2_mixer (скачиваются отдельно), отключаем.
SUPPORT_WAVPACK := false
SUPPORT_GME := false
APP_MODULES := main SDL2 SDL2_mixer SDL2_image SDL2_ttf freetype libiconv lua
