#!/bin/bash

# This script is to be used with my Sonarr/Radarr setup to automatically reencode shows to AV1.
# This script will attempt to be as easy to modify to fit your own needs, but don't expect it to be good.
# Fuck you <3
# Start date: 2024-02-09
# Last Update: 2024-05-22

# Deps
#
# FFMPEG
# mkvtoolnix
# Av1an (and it's requirements)


function vars() {
    # Some variables are filled in with defaults that some people recommend. Please still look everything over
    ulimit -n 20000 # Set this slightly higher if it still doesn't work for you
    readonly PATHS=() # Array for all paths you want to use, separated with a space
    readonly AV1AN_SPLIT_METHOD=av-scenechange # Valid options: av-scenechange (recommended), none
    readonly AV1AN_CHUNK_METHOD=lsmash # Valid options: segment, select, ffms2, lsmash (recommended), dgdecnv, bestsource, hybrid
    readonly AV1AN_CONCAT=mkvmerge # Valid options: ffmpeg, mkvmerge (recommended), ivf
    readonly AV1AN_ENC= # Valid options: svt-av1, rav1e, aomec
    readonly AV1AN_VENC_OPTS="" # Video encoding options
    readonly AV1AN_ENC_PIX=yuv420p # This is marked apparently as the most sane default so leave as is I guess??
    readonly AV1AN_AENC_OPTS="-c:a libopus -b:a 48k" # Audio encoding options
    readonly AV1AN_FFMPEG_OPTS="-map 0 -map -v -map V -c:s copy -strict -2" # The -f stuff in av1an
    readonly SET_TO_1=0 # Literally just a check to make you set variables so bugs don't happen.
}

function var_check() {
    if ! [[ $SET_TO_1 = 1 ]] # Read the comment likt 4 lines up or something
    then
        echo "[ * ] PLEASE EDIT THE SCRIPT AND ADD ALL FLAGS THAT ARE REQUIRED!"
        echo ""
        echo "      Please don't run random code you found online without checking it first"
        exit 1
    fi

    if [ -f /tmp/46620/scanner/lock ] # lock file check
    then
        echo "[ * ] LOCKFILE FOUND, ENCODER IS POSSIBLY RUNNING! IF IT'S NOT RUNNING PLEASE DELETE /tmp/46620/scanner/lock"
        exit 1
    fi  
}

function encode() {
    echo "[ * ] Encoding"
    mkdir -p /tmp/46620/scanner
    touch /tmp/46620/scanner/lock
    for paths in "${PATHS[@]}"
    do
        cd "$paths"
        # If you replace "." with ".mkv", you can delete the first ffprobe check. This is only here so it can work with any video container and not only mkv
        readarray -d '' files_array < <(find . -type f -print0)
        for file in "${files_array[@]}"
        do
            ffprobe "$file" |& grep "Video" &> /dev/null # Checking if the file is a video (this has several flaws, but can we NOT talk about that right now?) https://twitter.com/taceboi23/status/1727419892440420773/photo/1
            if [ $? -eq 1 ]
            then
                echo "[ * ] No video track"
                continue # I didn't know this was a thing
            fi
            ffprobe "$file" |& grep "Video: av1" &> /dev/null # Now we can check if the file is av1. I hate this shit btw it's actually terrible. 
            if [ $? -eq 0 ] # AV1
            then
                continue # file is AV1, do nothing
            fi
            ffprobe "$file" |& grep "Subtitle:" &> /dev/null # There has to be cleaner way to do this without a third check
            if [ $? -eq 0 ] # Subtitles
            then
                HAS_SUBS=1 # Var to fix subs
            else
                HAS_SUBS=0 # It fucking errors if there's no subtitles
            fi
            echo "[ * ] $file"
            du -hs "$file" >> "$paths/source-size.log"
            av1an -i "$file" -y --verbose --split-method "$AV1AN_SPLIT_METHOD" -m "$AV1AN_CHUNK_METHOD" -c "$AV1AN_CONCAT" -e "$AV1AN_ENC" --force -v "$AV1AN_VENC_OPTS" -a="$AV1AN_AENC_OPTS" --pix-format "$AV1AN_ENC_PIX" -f " $AV1AN_FFMPEG_OPTS " -x 240 -o "/tmp/`basename "${file%.*}"`.mkv"
            if [[ $HAS_SUBS -eq 1 ]]
            then
                echo "[ * ] Adding Subtitles"
                ffmpeg -i "$file" -i "/tmp/`basename "${file%.*}"`.mkv" -map 1:v -map 1:a -map 0:s -c:v copy -c:a copy -c:s copy -strict -2 "/tmp/`basename "${file%.*}"`-sub.mkv"
                if [ $? -eq 1 ]
                then
                    "[ * ] SUBTITLES ISSUE??? POSSIBLY CODEC 94213 RELATED! ATTEMPTING TO CONVERT TO SRT"
                    ffmpeg -y -i "$file" -i "/tmp/`basename "${file%.*}"`.mkv" -map 1:v -map 1:a -map 0:s -c:v copy -c:a copy -c:s srt -strict -2 "/tmp/`basename "${file%.*}"`-sub.mkv"
                    if [ $? -eq 1 ]
                    then
                        echo "[ * ] SUBS ARE FUCKED! GOD IS DEAD! $file NO LONGER HAS SUBTITLES!" >> "$paths/subtitles.log"
                    else
                        mv "/tmp/`basename "${file%.*}"`-sub.mkv" "/tmp/`basename "${file%.*}"`.mkv"
                    fi
                else
                    mv "/tmp/`basename "${file%.*}"`-sub.mkv" "/tmp/`basename "${file%.*}"`.mkv"
                fi
            fi
            echo "[ * ] Checking for file corruption"
            ffmpeg -v error -i "/tmp/`basename "${file%.*}"`.mkv" -f null - # TODO: BUILD A LIGHT FFMPEG TO SPEED THIS STEP UP BY 6x
            if [ $? -eq 0 ]
            then
                echo "[ * ] File encoded, replacing now"
                mv "/tmp/`basename "${file%.*}"`.mkv" "$file"
                du -hs "$file" >> "$paths/encode-size.log"
                continue
            else
                echo "[ * ] FILE CORRUPTED! NOT REPLACING"
                echo "REVIEW $file" >> "$paths/error.log"
            fi
        done
    done
}

function remove_lock() {
    echo "[ * ] REMOVING LOCKFILE"
    rm /tmp/46620/scanner/lock
}

function main() {
    vars
    var_check
    encode
    remove_lock
}

main
