#!/bin/sh

export ROOT_DIR=$(pwd)
export PROJECT_PATH=$ROOT_DIR/modules/instead_standalone
export LUAJIT_PATH=$PROJECT_PATH/jni/LuaJIT
export LUAJITM_PATH=$PROJECT_PATH/jni/LuaJIT_m
export NDK_HOME="/usr/local/apps/android-ndk-r14"
cd $LUAJITM_PATH
mkdir out
mkdir out/armeabi
mkdir out/armeabi-v7a
mkdir out/arm64-v8a
mkdir out/x86
mkdir out/x86_64
cd $LUAJIT_PATH
./make_armeabi.sh
./make_armeabi-v7a.sh
./make_arm64-v8a.sh
./make_x86.sh
./make_x86_64.sh