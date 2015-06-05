#!/bin/sh

export ROOT_DIR=$(pwd)
export NDK_HOME="/usr/local/android/android-ndk-r10c"
$NDK_HOME/ndk-build clean NDK_PROJECT_PATH=$ROOT_DIR/project NDK_APPLICATION_MK=$ROOT_DIR/Application.mk
$ROOT_DIR/clean.sh
$NDK_HOME/ndk-build NDK_PROJECT_PATH=$ROOT_DIR/project NDK_APPLICATION_MK=$ROOT_DIR/Application.mk
export LIBS_HOME="$ROOT_DIR/project/libs"
export RAW_HOME="$ROOT_DIR/project/res/raw"
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
cd $LIBS_HOME/x86
zip $RAW_HOME/libs_x86.zip *.so
for f in $(ls *.so)
do
  cat /dev/null > $f
done