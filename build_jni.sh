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
cd $ROOT_DIR
$NDK_HOME/ndk-build clean NDK_PROJECT_PATH=$PROJECT_PATH NDK_APPLICATION_MK=$ROOT_DIR/Application.mk
$ROOT_DIR/clean.sh
$NDK_HOME/ndk-build NDK_PROJECT_PATH=$PROJECT_PATH NDK_APPLICATION_MK=$ROOT_DIR/Application.mk
export LIBS_HOME="$PROJECT_PATH/libs"
export RAW_HOME="$PROJECT_PATH/res/raw"
cd $LIBS_HOME/armeabi
zip $RAW_HOME/libs_armeabi.zip *.so
for f in $(ls *.so)
do
  cat /dev/null > $f
done
cd $LIBS_HOME/armeabi-v7a
zip $RAW_HOME/libs_armeabi_v7a.zip *.so
for f in $(ls *.so)
do
  cat /dev/null > $f
done
cd $LIBS_HOME/arm64-v8a
zip $RAW_HOME/libs_arm64_v8a.zip *.so
for f in $(ls *.so)
do
  cat /dev/null > $f
done
cd $LIBS_HOME/x86
zip $RAW_HOME/libs_x86.zip *.so
for f in $(ls *.so)
do
  cat /dev/null > $f
done
cd $LIBS_HOME/x86_64
zip $RAW_HOME/libs_x86_64.zip *.so
for f in $(ls *.so)
do
  cat /dev/null > $f
done
cd $LUAJITM_PATH
rm -rf out