#!/bin/bash

# This is a rework of my old auto ctc script to support multiple builds
# For some reason when I did this all in functions it decided to just be a fuck fest of race conditions
# Branding, customversion, and eventually notrack and nonearby will be included in all builds by default
echo $JOB_BASE_NAME
user=`echo $JOB_BASE_NAME | cut -c 12-`
echo $user
case "$user" in
    46620)
        CTCPATCHES=(betterdmheader customversion disable-mobileindicator noblocked squareavatars)
        USE_BLOBS=1
        USE_MUTANT=0
        CUSTOM_ICON=1
        CTCBRANCH=CutTheCord
        CTCFORK=femboy
        ;;
    t3ch)
        CTCPATCHES=(betterdmheader)
        USE_BLOBS=0
        USE_MUTANT=0
        CTCBRANCH=Discord
        CTCFORK=disnuts
    ;;
    *)
        echo "This should literally not happen" >&2
        exit 1
esac

mkdir tmp
cd tmp
CTCTOP=`pwd`
CTCPATCHESPATH=$CTCTOP/cutthecord/patches
CTCBASE=$CTCTOP/com.discord

git clone https://booba.tech/CutTheCord/cutthecord.git
git clone --depth=1 https://booba.tech/CutTheCord/discord.git
cp -r discord/com.discord .

if [[ USE_BLOBS -eq 1 ]]
then
    git clone https://booba.tech/CutTheCord/blobs.git
    cd blobs
    export DISTOK_EMOJI_BLOBMOJI=`pwd`
    cd ..
elif [[ USE_MUTANT -eq 1 ]]
then
    echo "Mutant is currently not supported."
fi

cd cutthecord
export ver=`cat patchport-state.json | jq -r .versioncode`
cd patches/branding
python3 addpatch.py $ver.patch $CTCBRANCH $CTCFORK
cd $CTCBASE
export DISTOK_EXTRACTED_DISCORD_PATH=`pwd`
for cum in ${CTCPATCHES[@]}
    do
    	patch -p1 < "../cutthecord/patches/$cum/$ver.patch"
done

patch -p1 < "../cutthecord/patches/branding/$ver-custom.patch"

if [[ USE_BLOBS -eq 1 ]]
then
    python3 "../cutthecord/patches/blobs/emojireplace.py"
elif [[ USE_MUTANT -eq 1 ]]
then
    echo "Mutant is currently not supported."
fi

cd ..
git clone https://booba.tech/CutTheCord/ctc.git -b $user
cd com.discord
cp -rv ../ctc/res .

if [[ CUSTOM_ICON -eq 1 ]]
then
    bash "../cutthecord/patches/branding/customicon.sh"
    bash "../cutthecord/patches/branding/customdynamicicon.sh"
fi

apktool b
jarsigner -keystore /home/mia/ctc.keystore -storepass $keystore_passwd dist/com.cutthecord.$CTCFORK-$ver.apk ctc
