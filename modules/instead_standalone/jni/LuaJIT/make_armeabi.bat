rem set NDK_HOME=C:\Android\android-ndk-r14
set NDKABI=9
set NDKVER=%NDK_HOME%\toolchains\arm-linux-androideabi-4.9
set NDKP=%NDKVER%\prebuilt\windows-x86_64\bin\arm-linux-androideabi-
set NDKF=--sysroot %NDK_HOME%\platforms\android-%NDKABI%\arch-arm
mingw32-make HOST_CC="gcc -m32" CROSS=%NDKP% TARGET_FLAGS="%NDKF%" TARGET_SYS=Linux clean
mingw32-make HOST_CC="gcc -m32" CROSS=%NDKP% TARGET_FLAGS="%NDKF%" TARGET_SYS=Linux
copy .\src\libluajit.a .\..\LuaJIT_m\out\armeabi\
.\make_clean.bat