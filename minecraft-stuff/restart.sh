#!/bin/bash

########################
# Paper Restart Script #
########################
cd /opt/Minecraft # this script will assume that this is the path the server is in, please update if it is elsewhere

# Pull latest paper release
paperbase=https://papermc.io/api/v2/projects/paper/versions/1.17.1
paperlatestbuild=` curl -sL $paperbase | jq .builds[-1]`
wget -O server.jar "$paperbase/builds/$paperlatestbuild/downloads/paper-1.17.1-$paperlatestbuild.jar"

# Update Protocollib to latest 
echo "Updating ProtocolLib.jar"
wget -O "plugins/ProtocolLib.jar" "https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/target/ProtocolLib.jar" # Let's hope that this link stays static or else I will have to mirror it myself

# Update EssentialsX (and chat) to latest versions
# TODO: Make this not terrible to look at
echo "Updating EssentialsX + Chat"
essen=`curl https://ci.ender.zone/job/EssentialsX/api/json | jq .lastSuccessfulBuild.url | tr -d '"'`
essenlateapi=$essen\api/json
essenlate=`curl $essenlateapi | jq .artifacts[0].fileName | tr -d '"'`
essenchatlate=`curl $essenlateapi | jq .artifacts[2].fileName | tr -d '"'`
wget -O "plugins/EssentialsX.jar" https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/jars/$essenlate
wget -O "plugins/EssentialsXChat.jar" https://ci.ender.zone/job/EssentialsX/lastSuccessfulBuild/artifact/jars/$essenchatlate

java -Xms10G -Xmx10G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar nogui
systemctl --user restart minecraft
