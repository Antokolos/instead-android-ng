# Android/x86_64, x86_64, Android 5.0+
#NDK_HOME=/usr/local/apps/android-ndk-r14
NDKABI=21
NDKVER=$NDK_HOME/toolchains/x86_64-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/x86_64-linux-android-
NDKF="--sysroot $NDK_HOME/platforms/android-$NDKABI/arch-x86_64"
make HOST_CC="gcc -m64" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=Linux clean
make HOST_CC="gcc -m64" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=Linux
cp ./src/libluajit.so ./../LuaJIT_m/out/x86_64/
cp ./src/libluajit.a ./../LuaJIT_m/out/x86_64/
cp -r ./src/jit ./../LuaJIT_m/out/x86_64/
./make_clean.sh