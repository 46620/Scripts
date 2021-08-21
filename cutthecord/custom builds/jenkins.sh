#!/bin/bash

# This is a rework of my old auto ctc script to support multiple builds

user_set(){
    user=`echo $JOB_NAME_BASE | cut -c 12-`
    case "$user" in
        46620)
            CTCPATCHES=(betterdmheader customversion disable-mobileindicator noblocked squareavatars)
            USE_BLOBS=1
            CTCBRANCH=CutTheCord
            CTCFORK=femboy
            ;;
        t3ch)
            CTCPATCHES=(betterdmheader customversion disable-mobileindicator noblocked squareavatars)
            USE_BLOBS=1
            CTCNAME=Discord
            CTCBRANCH=disnuts
            ;;
        *)
            echo "This should literally not happen" >&2
            exit 1
    esac
}

setup(){
    mkdir tmp
    cd tmp
    git clone https://booba.tech/CutTheCord/cutthecord.git
    git clone --depth=1 https://booba.tech/CutTheCord/discord.git
    cp -r discord/com.discord .
}

emotes(){
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
}

patch() {
    cd cutthecord
    export ver=`cat patchport-state.json | jq -r .versioncode`
    cd patches/branding
    python addpatch.py $ver.patch $CTCNAME $CTCBRANCH
    cd ../../..
    cd com.discord
    export DISTOK_EXTRACTED_DISCORD_PATH=`pwd`
    for cum in ${CTCPATCHES[@]}
        do
    	    patch -p1 < "../cutthecord/patches/$cum/$ver.patch"
    done
    patch -p1 < "../cutthecord/patches/branding/$ver-custom.patch"
    if [[ USE_BLOBS -eq 1 ]]
    then
        python "../cutthecord/patches/blobs/emojireplace.py"
    elif [[ USE_MUTANT -eq 1 ]]
    then
        echo "Mutant is currently not supported."
    fi
}

res(){
    cd ..
    git clone https://booba.tech/CutTheCord/ctc.git -b $user
    cd com.discord
    cp -rv ../ctc/res .
    bash "../cutthecord/patches/branding/customicon.sh"
    bash "../cutthecord/patches/branding/customdynamicicon.sh"
}

build(){
    apktool b
    jarsigner -keystore /home/mia/ctc.keystore -storepass $keystore_passwd dist/com.cutthecord.femboy-$ver.apk ctc
}

main() {
    user_set
    setup
    emotes
    patch
    res
    build
}

main "$@"