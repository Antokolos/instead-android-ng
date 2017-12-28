APP_PROJECT_PATH := $(call my-dir)/modules/instead_standalone
APP_BUILD_SCRIPT := $(call my-dir)/modules/instead_standalone/jni/Android.mk
NDK_TOOLCHAIN_VERSION=4.9
APP_ABI := armeabi armeabi-v7a x86
APP_MODULES      := main lua SDL2 SDL2_mixer SDL2_image SDL2_ttf libiconv
