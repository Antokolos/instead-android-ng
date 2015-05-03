#!/bin/sh

export NDK_HOME="/usr/local/apps/android-ndk-r10d"
./clean.sh
$NDK_HOME/ndk-build NDK_PROJECT_PATH=./project NDK_APPLICATION_MK=./Application.mk
