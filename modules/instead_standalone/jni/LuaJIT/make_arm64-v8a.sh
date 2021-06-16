# Android/ARM64, arm64-v8a, Android 5.0+
#NDK_HOME=/usr/local/apps/android-ndk-r14
NDKABI=21
NDKVER=$NDK_HOME/toolchains/aarch64-linux-android-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/aarch64-linux-android-
NDKF="--sysroot $NDK_HOME/platforms/android-$NDKABI/arch-arm64"
NDKARCH="-march=armv8-a"
make HOST_CC="gcc -m64" CROSS=$NDKP TARGET_FLAGS="$NDKF $NDKARCH" TARGET_SYS=Linux clean
make HOST_CC="gcc -m64" CROSS=$NDKP TARGET_FLAGS="$NDKF $NDKARCH" TARGET_SYS=Linux
cp ./src/libluajit.so ./../LuaJIT_m/out/arm64-v8a/
cp ./src/libluajit.a ./../LuaJIT_m/out/arm64-v8a/
cp -r ./src/jit ./../LuaJIT_m/out/arm64-v8a/
./make_clean.sh