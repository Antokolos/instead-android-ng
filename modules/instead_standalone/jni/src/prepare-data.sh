#!/bin/bash

export RESPATH=./../../res/raw
export TOOLSDIR=/usr/local/apps/android-sdk-macosx/tools

if [ -f $TOOLSDIR/jobb ]
then
    rm $RESPATH/data.zip
    rm $RESPATH/games.zip
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
        $TOOLSDIR/jobb -v -pn com.nlbhub.instead.redhood -pv 105000 -d ./games -o ./main.105000.com.nlbhub.instead.redhood.obb
    else
        echo Bundled game archive does not exist, using tutorial3 game as default
        mkdir ./games/bundled
        cp -r ./instead/games/tutorial3/* ./games/bundled/
        zip -r $RESPATH/games.zip ./games
    fi
    rm -rf ./games
    cp ./instead/lang/* $RESPATH/data/lang
    cp ./instead/stead/* $RESPATH/data/stead
    cp -r ./instead/themes/* $RESPATH/data/themes
    cd $RESPATH/data
    zip -r ./../data.zip .nomedia *
    cd ..
    rm -rf data
else
    echo jobb utility cannot be found at $TOOLSDIR/jobb, please check that path is correct...
fi