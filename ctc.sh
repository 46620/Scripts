#####################
# CutTheCord builds #
#####################

############
# Clean up #
############
cd /opt/cutthecord
rm -rf *

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

#############
# Portpatch # (This is the reason the script should not be used btw )
#############
echo "Please note that if this fails, you will probably have a fucked build"
cd cutthecord
python3 patchport.py ../com.discord

######################
# Time to patch shit #
######################
