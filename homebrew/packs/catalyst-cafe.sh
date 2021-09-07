#!/bin/bash
#############################
# Ah shit, here we go again #
#############################

#########
# Notes #
#########
# This script currently only makes a mochaCFW setup with indexiine as I do not wanna manage 3 builds at once rn
# This script also downloads all the files in order from the guide with no real section. why? Cause I don't mod wii u's enough to know a better order.

############
# Download #
############

echo "Downloading WUP Installer GX2"
wget -q "https://wiiubru.com/appstore/zips/wup_installer_gx2.zip"
echo "Unzipping WUP"
unzip wup_installer_gx2.zip;rm wup_installer_gx2.zip info.json manifest.install screen1.png

echo "Downloading NANDdumper"
wget -q "https://www.wiiubru.com/appstore/zips/nanddumper.zip"
echo "Unzipping NANDdumper"
unzip nanddumper.zip;rm nanddumper.zip info.json manifest.install screen1.png

echo "Downloading hbappstore"
wget -q "https://github.com/fortheusers/hb-appstore/releases/download/2.2/wiiu-extracttosd.zip"
echo "Unzipping hbappstore"
unzip wiiu-extracttosd.zip;rm wiiu-extracttosd.zip

echo "Downloading hb launcher"
wget -q "https://github.com/dimok789/homebrew_launcher/releases/download/1.4/homebrew_launcher.v1.4.zip"
echo "Unzipping hb launcher"
unzip homebrew_launcher.v1.4.zip;rm homebrew_launcher.v1.4.zip

echo "Downloading Mocha"
wget -q "https://www.wiiubru.com/appstore/zips/mocha.zip"
echo "Unzipping Mocha"
unzip mocha.zip;rm mocha.zip info.json manifest.install

echo "Downloading indexiine installer"
wget -q "https://github.com/GaryOderNichts/indexiine-installer/releases/download/v2/indexiine-installer.zip"
echo "Unzipping indexiine installer"
unzip indexiine-installer.zip;rm indexiine-installer.zip

echo "Downloading SaveMii_Mod"
wget -q "https://wiiu.hacks.guide/docs/files/SaveMii_Mod.zip"
echo "Unzipping SaveMii_Mod"
unzip SaveMii_Mod.zip;rm SaveMii_Mod.zip

echo "Downloading mocha config"
wget -qO "wiiu/apps/mocha/config.ini" "https://wiiu.hacks.guide/docs/files/config.ini"

echo "Downloading the homebrew installer"
wget -qO "wiiu/payload.zip" "https://github.com/wiiu-env/homebrew_launcher_installer/releases/download/v1.4/payload.zip"
echo "Unzipping homebrew installer"
cd wiiu;unzip payload.zip;rm payload.zip;cd ..

###########
# Archive #
###########
echo "Create zip archive"
7z a -tzip "out/latest.zip" * > /dev/null
cd out
md5sum "latest.zip" > "latest.zip.md5"

###########
# Credits #
###########
# My friends that sat with me in the call while I worked on github shit instead of playing fortnite or osu
# Will Stetson for being the sing man
# Nintendo Homebrew for existing and helping people mod their systems
# My boyfriend for helping me through everything life throws at me, without him this github account would be bare