APP_PROJECT_PATH := $(call my-dir)/modules/instead_standalone
APP_BUILD_SCRIPT := $(call my-dir)/modules/instead_standalone/jni/Android.mk
NDK_TOOLCHAIN_VERSION=4.9
APP_STL := gnustl_shared
APP_PLATFORM := android-13
APP_ABI := armeabi armeabi-v7a x86
APP_MODULES      := main luajit SDL2 SDL2_mixer SDL2_image SDL2_ttf libiconv
