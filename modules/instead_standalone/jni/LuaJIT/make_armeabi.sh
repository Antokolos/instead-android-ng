# Android/ARM, armeabi (ARMv5TE soft-float), Android 2.2+ (Froyo)
NDK_HOME=/usr/local/apps/android-ndk-r14
NDKABI=9
NDKVER=$NDK_HOME/toolchains/arm-linux-androideabi-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-
NDKF="--sysroot $NDK_HOME/platforms/android-$NDKABI/arch-arm"
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=Linux clean
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=Linux
cp ./src/libluajit.a ./out/armeabi/
./make_clean.sh