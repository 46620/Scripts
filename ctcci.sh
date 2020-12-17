#####################
# CutTheCord builds #
#####################

cd /opt/cutthecord

#########################
# Download all the shit #
#########################

echo "Downloading latest version of discord"
curl -sL https://ws75.aptoide.com/api/7/app/getMeta?package_name=com.discord | jq -r '.data.file.path' | wget -i -
mv *.apk com.discord.apk
apktool d com.discord.apk

echo "Downloading cutthecord patches"
git clone --recursive https://gitdab.com/distok/cutthecord.git

echo "Downloading blobs"
git clone --recursive https://git.46620.moe/46620/blobs.git

echo "Downloading extra shit for build"
git clone --recursive https://git.46620.moe/46620/ctc.git

###############################
# Time to patch shit manually #
###############################
