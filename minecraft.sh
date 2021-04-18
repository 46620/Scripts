#!/bin/bash

########
# TODO #
########
# add https://ci.codemc.io/job/IsaiahPatton/job/Cardboard
# add essentials ci for plugins
#

cd /opt/Minecraft
wget -O paper.jar "https://ci.46620.moe/job/Auto%20Builds/job/Paper/lastSuccessfulBuild/artifact/paperclip.jar"
java -jar paper.jar nogui
systemctl --user restart minecraft.service
