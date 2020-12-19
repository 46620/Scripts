#!/bin/bash

############
# Env shit #
############
url=https://ws75.aptoide.com/api/7/app/getMeta?package_name=com.discord
ver=`curl -sL $url | jq -r '.data.file.vercode'`

cd /tmp
rm -rf discord/
rm com.discord.apk
curl -sL $url | jq -r '.data.file.path' | wget -i -
mv *.apk com.discord.apk
apktool d com.discord.apk
git clone https://git.46620.moe/46620/discord.git
rm -rf discord/com.discord
mv com.discord discord
cd discord
git add .
git commit -a -m "update to $ver"
git push
cd ..
