#!/bin/bash

cd launcher/assets
rm *.xml
curl -o game_list.xml -L http://instead.syscall.ru/pool/game_list.xml
curl -o game_list_alt.xml -L http://instead-games.ru/xml.php
curl -o game_list_nlb_demos.xml -L http://nlbproject.com/hub/services/getdemogames
curl -o game_list_nlb_full.xml -L http://nlbproject.com/hub/services/getfullgames
