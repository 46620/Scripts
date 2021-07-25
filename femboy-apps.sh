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
rm -rf *discord* # just in case something survived the first one that caused issues in the script
curl -sL $url | jq -r '.data.file.path' | wget -O "com.discord-$ver.apk" -i -
#mv *.apk com.discord-$ver.apk
md5sum com.discord-$ver.apk > discord.md5

if md5sum --status -c discord.md5; then
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
else
        echo "Hashes do not match, not going to push to gitlab"
        rm -rf *discord*
fi

##########
# Tiktok #
##########
url=https://ws75.aptoide.com/api/7/app/getMeta?package_name=com.zhiliaoapp.musically
ver=`curl -sL $url | jq -r '.data.file.vercode'`

cd /tmp
rm -rf *tiktok* # just in case something survived the first one that caused issues in the script
curl -sL $url | jq -r '.data.file.path' | wget -i -
mv *.apk com.tiktok-$ver.apk
md5sum com.tiktok-$ver.apk > tiktok.md5

if md5sum --status -c tiktok.md5; then
        apktool d com.tiktok-$ver.apk
        git clone https://git.46620.moe/femboy-apps/tiktok/tiktok.git
        rm -rf tiktok/com.tiktok
        cp -r com.tiktok-$ver tiktok/com.tiktok
        cd tiktok
        git add .
        git commit -a -m "update to $ver"
        git push
        cd ..
        rm -rf *tiktok*
else
        echo "Hashes do not match, not going to push to gitlab"
        rm -rf *tiktok*
fi
