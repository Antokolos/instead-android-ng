APP_ABI := arm64-v8a armeabi-v7a x86_64
APP_PLATFORM := android-21
APP_STL := c++_shared

# Legacy vendor C++ code (with register/narrowing) needs C++14.
APP_CPPFLAGS := -std=c++14 -Wno-c++11-narrowing

# bionic fortify false-positively aborts on old Lua 5.1 (strchr).
APP_CFLAGS := -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0

# NDK 28 no longer ships per-ABI *-strip wrappers, which AGP's strip task
# expects; strip release libraries at link time instead.
ifeq ($(NDK_DEBUG),0)
APP_LDFLAGS += -Wl,-s
endif

# Codecs whose external sources are not in the SDL2_mixer tree.
SUPPORT_WAVPACK := false
SUPPORT_GME := false

APP_MODULES := main SDL2 SDL2_mixer SDL2_image SDL2_ttf freetype libiconv lua
