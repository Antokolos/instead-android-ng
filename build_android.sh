#!/bin/sh

export ANT_HOME="/Users/Antokolos/Downloads/=programm=/apache-ant-1.9.4"

# Build APK
cd launcher
$ANT_HOME/bin/ant clean release

# Signing the APK -- see http://www.androiddevelopment.org/tag/apk/
cd ..

if [ -f Instead-NG-KS.keystore ]
then
    echo "Instead-NG-KS.keystore already exists"
else
    keytool -genkey -v -keystore Instead-NG-KS.keystore -alias Instead-NG -keyalg RSA -validity 10000
fi

jarsigner -verbose -keystore Instead-NG-KS.keystore "launcher/bin/Instead-NG-release-unsigned.apk" Instead-NG

echo ""
echo ""
echo "Checking if APK is verified..."
jarsigner -verify "launcher/bin/Instead-NG-release-unsigned.apk"