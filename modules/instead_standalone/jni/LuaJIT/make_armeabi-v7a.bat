rem set NDK_HOME=C:\Android\android-ndk-r14
set NDKABI=14
set NDKVER=%NDK_HOME%\toolchains\arm-linux-androideabi-4.9
set NDKP=%NDKVER%\prebuilt\windows-x86_64\bin\arm-linux-androideabi-
set NDKF=--sysroot %NDK_HOME%\platforms\android-%NDKABI%\arch-arm
set NDKARCH=-march=armv7-a -mfloat-abi=softfp -Wl,--fix-cortex-a8
mingw32-make HOST_CC="gcc -m32" CROSS=%NDKP% TARGET_FLAGS="%NDKF% %NDKARCH%" TARGET_SYS=Linux clean
mingw32-make HOST_CC="gcc -m32" CROSS=%NDKP% TARGET_FLAGS="%NDKF% %NDKARCH%" TARGET_SYS=Linux
copy .\src\libluajit.a .\..\LuaJIT_m\out\armeabi-v7a\
call .\make_clean.bat
