#!/bin/bash

git clone https://git.46620.moe/minecraft-server-shit/server-logs.git /tmp/logs/mc-logs
cd /tmp/logs/
mv /opt/Minecraft/logs/*.log.gz /tmp/logs
gunzip *.log.gz
sed -i -e 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/127.0.0.1/g' *.log
mv *.log mc-logs
cd mc-logs
git add .
git commit -m "New Logs"
git push
