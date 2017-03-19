# Android/x86, x86 (i686 SSE3), Android 4.0+ (ICS)
#NDK_HOME=/usr/local/apps/android-ndk-r14
NDKABI=14
NDKVER=$NDK_HOME/toolchains/x86-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/i686-linux-android-
NDKF="--sysroot $NDK_HOME/platforms/android-$NDKABI/arch-x86"
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=Linux clean
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=Linux
cp ./src/libluajit.so ./../LuaJIT_m/out/x86/
cp ./src/libluajit.a ./../LuaJIT_m/out/x86/
cp -r ./src/jit ./../LuaJIT_m/out/x86/
./make_clean.sh