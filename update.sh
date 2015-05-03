#!/bin/sh

export ANDROID_HOME="/usr/local/apps/android-sdk-macosx"

mv ./project/build.xml ./project/build.xml.prev

# Please note, the number '1' in '--target 1' below is the index of the android platform on your machine. To obtain it, execute 'android list targets' command
$ANDROID_HOME/tools/android update project --target 1 --path project --name Instead