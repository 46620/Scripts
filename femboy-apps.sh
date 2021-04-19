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
md5=`curl -sL $url | jq -r '.data.file.md5sum'`

cd /tmp
rm -rf *discord* # just in case something survived the first one that caused issues in the script
curl -sL $url | jq -r '.data.file.path' | wget -i -
mv *.apk com.discord-$ver.apk
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

# You might be asking why I didn't do any md5 verification for instagram, it's because it has never given me an issue when I pull it from aptoide