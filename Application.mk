APP_PROJECT_PATH := $(call my-dir)/modules/instead_standalone
APP_BUILD_SCRIPT := $(call my-dir)/modules/instead_standalone/jni/Android.mk
NDK_TOOLCHAIN_VERSION=4.9
APP_ABI := armeabi armeabi-v7a x86
APP_MODULES      := main lua jpeg webp smpeg2 SDL2 SDL2_mixer tremor SDL2_image png SDL2_ttf freetype libiconv mad mikmod
