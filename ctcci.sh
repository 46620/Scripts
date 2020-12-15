#####################
# CutTheCord builds #
#####################

cd /opt/cutthecord

echo "Downloading latest version of discord"
curl -sL https://ws75.aptoide.com/api/7/app/getMeta?package_name=com.discord | jq -r '.data.file.path' | wget -i -

mv *.apk com.discord.apk

###############################
# Time to patch shit manually #
###############################

git clone --recursive https://gitdab.com/distok/cutthecord.git
apktool d com.discord.apk