#!/bin/bash

# This is a rework of my old auto ctc script to support multiple builds
# For some reason when I did this all in functions it decided to just be a fuck fest of race conditions
# Branding and notrack will be included in all builds by default

# notrack is no longer included by default as it is possibly linked to accounts being temp locked
#

# Jenkins user selection

echo $JOB_BASE_NAME
user=`echo $JOB_BASE_NAME | cut -c 12-`
echo $user
case "$user" in
    46620)
        CTCPATCHES=(betterdmheader customversion disable-mobileindicator profilemention)
        XMLPATCHES=(betterdmheader noblocked squareavatars)
        USE_BLOBS=1
        USE_MUTANT=0
        CUSTOM_RES=1
        CUSTOM_ICON=1
        CTCBRANCH=CutTheCord
        CTCFORK=femboy
        ;;
    t3ch)
        CTCPATCHES=(betterdmheader profilemention)
        XMLPATCHES=(betterdmheader)
        USE_BLOBS=0
        USE_MUTANT=0
        CUSTOM_RES=1
        CUSTOM_ICON=0
        CTCBRANCH=Discord
        CTCFORK=disnuts
    ;;
    *)
        echo "This should literally not happen" >&2
        exit 1
esac

# Make small temp work dir and set vars

mkdir tmp
cd tmp
CTCTOP="`pwd`"
CTCRES="$CTCTOP/cutthecord/resources/res"
CTCPATCHESPATH="$CTCTOP/cutthecord/resources/patches"
CTCXMLPATCHESPATH="$CTCTOP/cutthecord/resources/xmlpatches"
CTCBASE="$CTCTOP/com.discord"

# Clone the shit

git clone https://booba.tech/CutTheCord/cutthecord.git
git clone --depth=1 https://booba.tech/CutTheCord/discord.git
cp -r discord/com.discord .

# Find out what emote set the user wants

if [[ USE_BLOBS -eq 1 ]]
then
    git clone https://booba.tech/CutTheCord/blobs.git
    cd blobs
    export DISTOK_EMOJI_BLOBMOJI="`pwd`"
    cd "$CTCTOP"
elif [[ USE_MUTANT -eq 1 ]]
then
    echo "Mutant is currently not supported."
fi

# Start patching

cd "$CTCTOP/cutthecord/resources/"
export ver=`cat patchport-state.json | jq -r .versioncode`
cd patches/branding
python3 addpatch.py $ver.patch $CTCBRANCH $CTCFORK
cd "$CTCBASE"
export DISTOK_EXTRACTED_DISCORD_PATH=`pwd`
for cum in ${CTCPATCHES[@]}
    do
    	patch -p1 < "$CTCPATCHESPATH/$cum/$ver.patch"
done
# New exotic xml patches
for cum2 in ${XMLPATCHES[@]}
    do
    	xml-patch --patch "$CTCXMLPATCHESPATH/$cum2/$cum2.xml" --srcdir "$CTCBASE"
done

# Required patches
patch -p1 < "$CTCPATCHESPATH/branding/$ver-custom.patch"
#patch -p1 < "$CTCPATCHESPATH/notrack/$ver.patch"
#xml-patch --patch "$CTCXMLPATCHESPATH/notrack/$ver.xml" --srcdir "$CTCBASE"
#bash "$CTCPATCHESPATH/notrack/$ver-post.sh" <-- This caused the app to not start

# Now use said emotes you wanted

if [[ USE_BLOBS -eq 1 ]]
then
    python3 "$CTCPATCHESPATH/blobs/emojireplace.py"
elif [[ USE_MUTANT -eq 1 ]]
then
    echo "Mutant is currently not supported."
fi

# Custom res settings

if [[ CUSTOM_RES -eq 1 ]]
then
cp -rv ../cutthecord/resources/res/$user/res .
fi

# Addon to custom res

if [[ CUSTOM_ICON -eq 1 ]]
then
    bash "$CTCPATCHESPATH/branding/customicon.sh"
    bash "$CTCPATCHESPATH/branding/customdynamicicon.sh"
fi

# Build this bitch

apktool b
jarsigner -keystore /home/mia/ctc.keystore -storepass $keystore_passwd dist/com.cutthecord.$CTCFORK-$ver.apk ctc
