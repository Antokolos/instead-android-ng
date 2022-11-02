#!/bin/bash

cd launcher/assets
rm *.xml
curl -k -o game_list.xml -L http://instead-games.ru/xml.php
curl -k -o game_list_alt.xml -L http://instead-games.ru/xml2.php
curl -k -o nlbproject_games.xml -L https://nlbproject.com/hub/services/nlbproject_games
curl -k -o community_games.xml -L https://nlbproject.com/hub/services/community_games
