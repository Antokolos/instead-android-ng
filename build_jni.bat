rem @echo off
set ROOT_DIR=%~dp0
set A7Z="C:\Program Files\7-Zip\7z.exe"
set PROJECT_PATH=%ROOT_DIR%\modules\instead_standalone
set LUAJIT_PATH=%PROJECT_PATH%\jni\LuaJIT
set LUAJITM_PATH=%PROJECT_PATH%\jni\LuaJIT_m
rem Please install NDK to path without spaces, and don't use the quotes, it will break build of LuaJIT
set NDK_HOME=C:\Android\android-ndk-r14
cd %LUAJITM_PATH%
mkdir out
mkdir out\armeabi
mkdir out\armeabi-v7a
mkdir out\x86
cd %LUAJIT_PATH%
call .\make_armeabi.bat
call .\make_armeabi-v7a.bat
call .\make_x86.bat
cd %ROOT_DIR%
%NDK_HOME%\ndk-build clean NDK_PROJECT_PATH=%PROJECT_PATH% NDK_APPLICATION_MK=%ROOT_DIR%\Application.mk
call %ROOT_DIR%\clean.bat
%NDK_HOME%\ndk-build NDK_PROJECT_PATH=%PROJECT_PATH% NDK_APPLICATION_MK=%ROOT_DIR%\Application.mk
set LIBS_HOME=%PROJECT_PATH%\libs
set RAW_HOME=%PROJECT_PATH%\res\raw
cd %LIBS_HOME%\armeabi
%A7Z% a %RAW_HOME%\libs_armeabi.zip *.so
for %%f in (.\*.so) do copy /Y nul: %%f
cd $LIBS_HOME\armeabi-v7a
%A7Z% a %RAW_HOME%\libs_armeabi_v7a.zip *.so
for %%f in (.\*.so) do copy /Y nul: %%f
cd %LIBS_HOME%\x86
%A7Z% %RAW_HOME%\libs_x86.zip *.so
for %%f in (.\*.so) do copy /Y nul: %%f
cd %LUAJITM_PATH%
rd /s /q out