#!/bin/sh

export ANDROID_HOME="/usr/local/apps/android-sdk-macosx"

mv ./launcher/build.xml ./launcher/build.xml.prev
mv ./modules/instead_standalone/build.xml ./modules/instead_standalone/build.xml.prev
mv ./modules/play_apk_expansion/build.xml ./modules/play_apk_expansion/build.xml.prev
mv ./modules/play_licensing/build.xml ./modules/play_licensing/build.xml.prev


# Please note, the number '2' in '--target 2' below is the index of the android platform on your machine. To obtain it, execute 'android list targets' command
$ANDROID_HOME/tools/android update project --subprojects --target 2 --path launcher --name Instead-NG
$ANDROID_HOME/tools/android update project --subprojects --target 2 --path modules/instead_standalone --name instead_standalone
$ANDROID_HOME/tools/android update project --subprojects --target 2 --path modules/play_apk_expansion --name play_apk_expansion
$ANDROID_HOME/tools/android update project --subprojects --target 2 --path modules/play_licensing --name play_licensing