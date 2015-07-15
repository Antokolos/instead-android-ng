#!/bin/bash

export RESPATH=./../../res/raw
export TOOLSDIR=/usr/local/apps/android-sdk-macosx/tools

if [ -f $TOOLSDIR/jobb ]
then
    rm $RESPATH/data.zip
    mkdir $RESPATH/data
    unzip -x ./data.zip -d $RESPATH/data
    mkdir ./games
    mkdir ./games/games
    if [ -f ./bundled.zip ]
    then
        echo Bundled game archive exists, using it as default    
        unzip -x ./bundled.zip -d ./games/games
        export GAMENAME=`ls -1 ./games/games`
        mv ./games/games/$GAMENAME ./games/games/bundled
    else
        echo Bundled game archive does not exist, using tutorial3 game as default
        mkdir ./games/games/bundled
        cp ./instead/games/tutorial3/* ./games/games/bundled/
    fi
    $TOOLSDIR/jobb -v -pn com.nlbhub.instead -pv 100000 -d ./games -o ./main.100000.com.nlbhub.instead.obb
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