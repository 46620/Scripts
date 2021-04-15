#!/bin/bash

# This script is just to pull the latest version of apps to my gitlab server to be patched with new stuff (or as a backup for old versions)

############
# Env shit #
############
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"

###########
# Discord #
###########
url=https://ws75.aptoide.com/api/7/app/getMeta?package_name=com.discord
ver=`curl -sL $url | jq -r '.data.file.vercode'`

cd /tmp
curl -sL $url | jq -r '.data.file.path' | wget -i -
mv *.apk com.discord-$ver.apk
apktool d com.discord-$ver.apk
git clone https://git.46620.moe/femboy-apps/discord/discord.git
rm -rf discord/com.discord
cp -r com.discord-$ver discord/com.discord
cd discord
git add .
git commit -a -m "update to $ver"
git push
cd ..
rm -rf *discord*

#############
# Instagram #
#############

url=https://ws75.aptoide.com/api/7/app/getMeta?package_name=com.instagram.android
ver=`curl -sL $url | jq -r '.data.file.vercode'`

cd /tmp
curl -sL $url | jq -r '.data.file.path' | wget -i -
mv *.apk com.instagram.apk
apktool d com.instagram.apk
git clone https://git.46620.moe/femboy-apps/instagram/instagram.git
rm -rf instagram/com.instagram
cp -r com.instagram instagram
cd instagram
git add .
git commit -a -m "update to $ver"
git push
cd ..
rm -rf *instagram*
