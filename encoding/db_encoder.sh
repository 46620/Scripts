#!/bin/bash

# Version: 2.0

# Fuck you and fuck my sanity <3
# Start date:   2024-02-09
# Last Rewrite: 2024-08-28
# Last Update:  2024-08-29

# Deps
#
# FFMPEG
# mkvtoolnix
# Av1an (and it's requirements)
# sqlite3

# I got a shell checker :))
# shellcheck disable=2164 # that fucking cd || exit shit
# shellcheck disable=2317 # Unused code (trap ctrl_c screamed)

function pre_check() {
    trap ctrl_c INT
    if ! [ -f media.env ]
    then
        echo "[  *] media.env not found, downloading example file"
        wget -O media.env "https://raw.githubusercontent.com/46620/Scripts/master/encoding/media.env.example"
    else
        source media.env
    fi
    if ! [ -f "$DB_PATH/$DATABASE_NAME".db ]
    then
        echo " [  *] DATABASE IS MISSING! PLEASE RUN THE CREATE SCRIPT!"
        exit 1
    fi
    if [ -d TOOLS ]
    then
        echo " [*  ] TOOLS DIR FOUND! ADDING TO PATH"
        PATH=$(pwd)/TOOLS:$PATH
    fi
}

function var_check() {
    if ! [[ $media_env_check = true ]]
    then
        echo " [  *] PLEASE CHECK THE ENV FILE AND READ THIS SCRIPT!"
        exit 1
    fi

    if [ -f "$LOCKDIR/$ENCODER_LOCKFILE" ]
    then
        echo " [  *] LOCKFILE FOUND, ENCODER IS POSSIBLY RUNNING! IF IT'S NOT RUNNING PLEASE DELETE $LOCKDIR/$ENCODER_LOCKFILE"
        exit 1
    fi
}

function encode() {
    echo " [*  ] Encoding"
    mkdir -p "$LOCKDIR"
    touch "$LOCKDIR/$ENCODER_LOCKFILE"
    cd "$MEDIA_ROOT"
    touch {source-size,encode-size,error,subtitle}.log
    readarray encode_these < <(sqlite3 "$DB_PATH/$DATABASE_NAME".db "SELECT * FROM $ENCTABLE_NAME")
    for file in "${encode_these[@]}"
    do
        file=$(echo "$file" | head -n1) # don't ask why I added this hacky fucking workaround, I do not know either but it makes it work. fucking retarded ass shell language I need to learn go
        ffprobe "$file" |& grep "Subtitle:" &> /dev/null
        if [ $? -eq 0 ] # Subtitles
        then
            HAS_SUBS=1 # Var to fix subs
        else
            HAS_SUBS=0
        fi
        echo " [*  ] $file"
        du -hs "$file" >> "$MEDIA_ROOT/source-size.log"
        av1an -i "$file" -y --verbose --split-method "$AV1AN_SPLIT_METHOD" -m "$AV1AN_CHUNK_METHOD" -c "$AV1AN_CONCAT" -e "$AV1AN_ENC" --force -v "$AV1AN_VENC_OPTS" -a="$AV1AN_AENC_OPTS" --pix-format "$AV1AN_ENC_PIX" -f " $AV1AN_FFMPEG_OPTS " -x 240 -o "/tmp/$(basename "${file%.*}").mkv"
        if [[ $HAS_SUBS -eq 1 ]]
        then
            echo " [*  ] Adding Subtitles"
            ffmpeg -i "$file" -i "/tmp/$(basename "${file%.*}").mkv" -map 1:v -map 1:a -map 0:s -c:v copy -c:a copy -c:s copy -strict -2 "/tmp/`basename "${file%.*}"`-sub.mkv" &> /dev/null
            if [ $? -eq 1 ]
            then
                echo " [ * ] SUBTITLES ISSUE??? POSSIBLY CODEC 94213 RELATED! ATTEMPTING TO CONVERT TO SRT"
                ffmpeg -y -i "$file" -i "/tmp/$(basename "${file%.*}").mkv" -map 1:v -map 1:a -map 0:s -c:v copy -c:a copy -c:s srt -strict -2 "/tmp/`basename "${file%.*}"`-sub.mkv" &> /dev/null
                if [ $? -eq 1 ]
                then
                    echo " [  *] SUBS ARE FUCKED! GOD IS DEAD! $file NO LONGER HAS SUBTITLES!" >> "$MEDIA_ROOT/subtitles.log"
                else
                    mv "/tmp/$(basename "${file%.*}")-sub.mkv" "/tmp/$(basename "${file%.*}").mkv"
                fi
            else
                mv "/tmp/$(basename "${file%.*}")-sub.mkv" "/tmp/$(basename "${file%.*}").mkv"
            fi
        fi
        echo " [*  ] Checking for file corruption"
        ffmpeg -v error -i "/tmp/$(basename "${file%.*}").mkv" -f null - # TODO: build a light ffmpeg to speed this step up. might cause issues with av1an so name it ffmpeg2 or some shit
        if [ $? -eq 0 ]
        then
            echo " [*  ] File encoded, replacing now"
            mv "/tmp/$(basename "${file%.*}").mkv" "$file"
            mv "$file" "${file%.*}".mkv &> /dev/null # Forces file to be mkv, there isn't any issue if it's already mkv
            du -hs "$file" >> "$MEDIA_ROOT/encode-size.log"
            echo " [*  ] Removing file from database"s
            file_escaped=$(echo "$file" | sed "s/'/''/g")
            sqlite3 "$DB_PATH/$DATABASE_NAME".db "DELETE FROM $ENCTABLE_NAME WHERE file = '$file_escaped'"
            continue
        else
            echo " [  *] FILE CORRUPTED! NOT REPLACING"
            echo "REVIEW $file" >> "$MEDIA_ROOT/error.log"
        fi
    done
}

function cleanup() {
    echo " [*  ] All files now encoded. Please check logs for any issues."
    echo " [*  ] Cleaning up script"
    cd "$MEDIA_ROOT"
    rm -rf .*
    rm "$LOCKDIR/$ENCODER_LOCKFILE"
    exit
}

function ctrl_c() {
    echo " [  *] USER EXITING SCRIPT! RUN MASS CLEANUP JOB!"
    cd "$MEDIA_ROOT"
    rm -rf .*
    rm "$LOCKDIR/$ENCODER_LOCKFILE"
    exit 1
}

function main() {
    pre_check
    var_check
    encode
    cleanup
}

main