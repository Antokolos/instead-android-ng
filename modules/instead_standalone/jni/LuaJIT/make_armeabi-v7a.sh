# Android/ARM, armeabi-v7a (ARMv7 VFP), Android 4.0+ (ICS)
NDK_HOME=/usr/local/apps/android-ndk-r14
NDKABI=14
NDKVER=$NDK_HOME/toolchains/arm-linux-androideabi-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-
NDKF="--sysroot $NDK_HOME/platforms/android-$NDKABI/arch-arm"
NDKARCH="-march=armv7-a -mfloat-abi=softfp -Wl,--fix-cortex-a8"
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF $NDKARCH" TARGET_SYS=Linux clean
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF $NDKARCH" TARGET_SYS=Linux
cp ./src/libluajit.a ./out/armeabi-v7a/
./make_clean.sh