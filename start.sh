#!/bin/bash
screen -wipe

cd /opt/Minecraft
wget "https://papermc.io/ci/job/Paper-1.16/lastSuccessfulBuild/artifact/*zip*/archive.zip"
unzip archive.zip
mv archive/paperclip.jar ./paper.jar
rm -rf wget*
rm -rf archiv*
java -jar paper.jar nogui
systemctl --user restart minecraft.service
