#!/bin/bash

cd project/assets
rm *.xml
wget -c http://instead-launcher.googlecode.com/svn/pool/game_list.xml
wget -c http://instead-launcher.googlecode.com/svn/pool/game_list_alt.xml