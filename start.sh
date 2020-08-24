#!/bin/bash
screen -wipe
cd /opt/Minecraft
rm archive.zip # If script was stopped while downloading the script this will prevent archive.zip.1 from happening
wget "https://papermc.io/ci/job/Paper-1.16/lastSuccessfulBuild/artifact/*zip*/archive.zip"
unzip archive.zip
mv archive/paperclip.jar ./paper.jar
rm -rf wget*
rm -rf archive*
screen -dmS mc -d java -jar paper.jar
