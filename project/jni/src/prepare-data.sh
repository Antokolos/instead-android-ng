#!/bin/bash

export RESPATH=./../../res/raw

rm $RESPATH/data.zip
mkdir $RESPATH/data
unzip -x ./data.zip -d $RESPATH/data
if [ -f ./bundled.zip ]
then
    echo Bundled game archive exists, using it as default
    rm -rf $RESPATH/data/appdata/games/bundled
    unzip -x ./bundled.zip -d $RESPATH/data/appdata/games
    export GAMENAME=`ls -1 $RESPATH/data/appdata/games`
    mv $RESPATH/data/appdata/games/$GAMENAME $RESPATH/data/appdata/games/bundled
else
    echo Bundled game archive does not exist, using tutorial3 game as default
    cp ./instead/games/tutorial3/* $RESPATH/data/appdata/games/bundled
fi
cp ./instead/lang/* $RESPATH/data/lang
cp ./instead/stead/* $RESPATH/data/stead
cp -r ./instead/themes/* $RESPATH/data/themes
cd $RESPATH/data
zip -r ./../data.zip .nomedia *
cd ..
rm -rf data