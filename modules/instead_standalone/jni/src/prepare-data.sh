#!/bin/bash

export RESPATH=./../../res/raw
export TOOLSDIR=/usr/local/apps/android-sdk-macosx/tools

if [ -f $TOOLSDIR/jobb ]
then
    rm $RESPATH/data.zip
    rm $RESPATH/games.zip
    rm $RESPATH/themes.zip
    mkdir $RESPATH/data
    unzip -x ./data.zip -d $RESPATH/data
    mkdir ./games
    if [ -f ./bundled.zip ]
    then
        echo Bundled game archive exists, using it as default
        mkdir ./games/games
        unzip -x ./bundled.zip -d ./games/games
        export GAMENAME=`ls -1 ./games/games`
        # The following folder will be used instead of appdata folder (personal preferences & saves folder)
        mkdir $RESPATH/data/$GAMENAME
        $TOOLSDIR/jobb -v -pn com.nlbhub.instead.barbariancaves -pv 185005 -d ./games -o ./main.185005.com.nlbhub.instead.barbariancaves.obb
        # Create (almost) empty archive structure for games, we will use OBB file for actual game content
        rm -rf ./games/games
        mkdir ./games/bundled
        touch ./games/.nomedia
    else
        echo Bundled game archive does not exist, using tutorial3 game as default
        mkdir ./games/bundled
        touch ./games/.nomedia        
        cp -r ./instead/games/tutorial3/* ./games/bundled/
    fi
    cp ./instead/lang/* $RESPATH/data/lang
    rm -f $RESPATH/data/lang/CMakeLists.txt
    rm -f $RESPATH/data/lang/Makefile
    rm -f $RESPATH/data/lang/Makefile.windows
    
    zip -r $RESPATH/games.zip ./games
    rm -rf ./games
    cp -r ./instead/stead/* $RESPATH/data/stead
    rm -f $RESPATH/data/stead/CMakeLists.txt
    rm -f $RESPATH/data/stead/Makefile
    rm -f $RESPATH/data/stead/Makefile.windows
    cp -r ./instead/themes/* $RESPATH/data/themes
    rm -f $RESPATH/data/themes/CMakeLists.txt
    rm -f $RESPATH/data/themes/Makefile
    rm -f $RESPATH/data/themes/Makefile.windows
    cd $RESPATH/data    
    cp .nomedia themes
    zip -r ./../themes.zip themes
    rm -rf themes
    zip -r ./../data.zip .nomedia *    
    cd ..
    rm -rf data
else
    echo jobb utility cannot be found at $TOOLSDIR/jobb, please check that path is correct...
fi