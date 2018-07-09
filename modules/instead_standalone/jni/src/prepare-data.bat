set CUR_DIR=%~dp0
set A7Z="C:\Program Files\7-Zip\7z.exe"
set RESPATH=%CUR_DIR%\..\..\res\raw
set TOOLSDIR=C:\Program Files (x86)\Android\android-sdk\tools

if exist "%TOOLSDIR%\jobb.bat" (
    del /Q %RESPATH%\data.zip
    del /Q %RESPATH%\games.zip
    del /Q %RESPATH%\themes.zip
    mkdir %RESPATH%\data
    if exist "%CUR_DIR%/bundled.zip" (
        echo "Creation of archives from bundled game archive is not supported for now, use *nix Systems"
        exit
        rem TODO: Handle case with bundled game archive
        rem unzip -x ./datast.zip -d $RESPATH/data
        rem mkdir ./games
        rem echo Bundled game archive exists, using it as default
        rem mkdir ./games/games
        rem unzip -x ./bundled.zip -d ./games/games
        rem export GAMENAME=`ls -1 ./games/games`
        rem # The following folder will be used instead of appdata folder (personal preferences & saves folder)
        rem mkdir $RESPATH/data/$GAMENAME
        rem $TOOLSDIR/jobb -v -pn com.nlbhub.instead.redhood -pv 105000 -d ./games -o ./main.105000.com.nlbhub.instead.redhood.obb
        rem # Please note, lang files are not copied for bundled games, we are using the ones in the datast.zip archive
        rem # Create (almost) empty archive structure for games, we will use OBB file for actual game content
        rem rm -rf ./games/games
        rem mkdir ./games/bundled
        rem touch ./games/.nomedia
    ) else (
        %A7Z% x -o%RESPATH%\data %CUR_DIR%\data.zip
        mkdir %CUR_DIR%\games
        copy /y NUL %CUR_DIR%\games\.nomedia >NUL
        echo Bundled game archive does not exist, using tutorial3 game as default
        mkdir %CUR_DIR%\games\bundled
        robocopy %CUR_DIR%\instead\games\tutorial3\ %CUR_DIR%\games\bundled\ /MIR
        robocopy %CUR_DIR%\instead\lang\ %RESPATH%\data\lang /MIR
        del /Q %RESPATH%\data\lang\CMakeLists.txt
        del /Q %RESPATH%\data\lang\Makefile
        del /Q %RESPATH%\data\lang\Makefile.windows
    )
    %A7Z% a %RESPATH%\games.zip %CUR_DIR%\games
    rd /S /Q %CUR_DIR%\games
    robocopy %CUR_DIR%\instead\stead\ %RESPATH%\data\stead /MIR
    robocopy %CUR_DIR%\lua\stead2\ %RESPATH%\data\stead\stead2 /MIR
    robocopy %CUR_DIR%\lua\stead3\ %RESPATH%\data\stead\stead3 /MIR
    del /Q %RESPATH%\data\stead\CMakeLists.txt
    del /Q %RESPATH%\data\stead\Makefile
    del /Q %RESPATH%\data\stead\Makefile.windows
    robocopy %CUR_DIR%\instead\themes\ %RESPATH%\data\themes /S
    del /Q %RESPATH%\data\themes\CMakeLists.txt
    del /Q %RESPATH%\data\themes\Makefile
    del /Q %RESPATH%\data\themes\Makefile.windows
    cd %RESPATH%\data    
    copy /y .nomedia themes
    %A7Z% a %RESPATH%\themes.zip themes
    rd /S /Q themes
    %A7Z% a %RESPATH%\data.zip .nomedia *    
    cd ..
    rd /S /Q data
) else (
    echo jobb utility cannot be found at "%TOOLSDIR%", please check that path is correct...
)