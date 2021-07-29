#!/bin/bash

# This script is just to pull the latest version of apps to my gitlab server to be patched with new stuff (or as a backup for old versions)

#
# Env Shit
#
# Due to some issue with cron I have to set this, does it make sense? Nope not at all
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
urlbase="https://ws75.aptoide.com/api/7/app/getMeta?package_name="

#
# Discord
#
app=$urlbase\com.discord
ver=`curl -sL $app | jq -r '.data.file.vercode'`
md5sum=`curl -sL $app | jq -r '.data.file.md5sum'`

cd /tmp
rm -rf *discord* # Safety delete cause shit be brokey sometimes
curl -sL $app | jq -r '.data.file.path' | wget -O "com.discord-$ver.apk" -i -
#md5sum com.discord-$ver.apk > discord.md5
echo "$md5sum  com.discord-$ver.apk" > discord.md5
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