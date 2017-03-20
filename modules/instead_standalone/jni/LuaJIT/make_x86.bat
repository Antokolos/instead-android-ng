rem set NDK_HOME=C:\Android\android-ndk-r14
set NDKABI=14
set NDKVER=%NDK_HOME%\toolchains\x86-4.9
set NDKP=%NDKVER%\prebuilt\windows-x86_64\bin\i686-linux-android-
set NDKF=--sysroot %NDK_HOME%\platforms\android-%NDKABI%\arch-x86
mingw32-make HOST_CC="gcc -m32" CROSS=%NDKP% TARGET_FLAGS="%NDKF%" TARGET_SYS=Linux clean
mingw32-make HOST_CC="gcc -m32" CROSS=%NDKP% TARGET_FLAGS="%NDKF%" TARGET_SYS=Linux
copy .\src\libluajit.a .\..\LuaJIT_m\out\x86\
call .\make_clean.bat
