#!/bin/bash

# Version: 202501101

# Start date:   2024-02-09
# Last Rewrite: 2024-08-28

# shellcheck disable=2164 # that "cd || exit" thing that I hate
# shellcheck disable=2317 # Unused code (trap ctrl_c screamed)

function pre_check() {
    trap ctrl_c INT
    if ! [ -f media.env ]
    then
        echo "[  *] media.env not found, grabbing example."
        wget -O media.env.example "https://raw.githubusercontent.com/46620/Scripts/master/encoding/media.env.example"
        echo "[ * ] please edit media.env and then restart the script."
        exit 1
    else
        source media.env
    fi
    if ! [ -f "$DB_PATH/$DATABASE_NAME".db ]
    then
        echo " [  *] DATABASE IS MISSING! PLEASE RUN THE CREATE SCRIPT!"  # TODO: RUN DB_CREATE INSTEAD OF ERRORING!
        exit 1
    fi
    if [ -d TOOLS ]
    then
        echo " [*  ] TOOLS DIR FOUND! ADDING TO PATH!"
        PATH=$(pwd)/TOOLS:$PATH
    fi
}

function var_check() {
    if [ -f "$LOCKDIR/$ENCODER_LOCKFILE" ]
    then
        echo " [  *] LOCKFILE FOUND, ENCODER IS POSSIBLY RUNNING! IF IT'S NOT RUNNING PLEASE DELETE $LOCKDIR/$ENCODER_LOCKFILE!"
        exit 1
    fi
}

function encode() {
    echo " [*  ] Encoding"
    mkdir -p "$LOCKDIR";touch "$LOCKDIR/$ENCODER_LOCKFILE"
    cd "$MEDIA_ROOT"
    mkdir -p "$MEDIA_TMP"  # 20250308: finally adding something to speed up resume encodes
    touch {source-size,encode-size,error,subtitle}.log
    readarray encode_these < <(sqlite3 "$DB_PATH/$DATABASE_NAME".db "SELECT * FROM $ENCTABLE_NAME")
    for file in "${encode_these[@]}"
    do
        file=$(echo "$file" | head -n1)  # The way I grab file names caused a newline after every file name, this fixes it
        if ffprobe "$file" |& grep -q "Subtitle:"  # Subtitles
        then
            HAS_SUBS=1  # Var to fix subs
        else
            HAS_SUBS=0
        fi
        echo " [*  ] $file"
        du -hs "$file" >> "$MEDIA_ROOT/source-size.log"
        av1an -i "$file" -y -r --temp "$MEDIA_TMP/$(basename "${file%.*}")" --verbose --split-method "$AV1AN_SPLIT_METHOD" -m "$AV1AN_CHUNK_METHOD" -c "$AV1AN_CONCAT" -e "$AV1AN_ENC" --force -v "$AV1AN_VENC_OPTS" -a="$AV1AN_AENC_OPTS" --pix-format "$AV1AN_ENC_PIX" -f " $AV1AN_FFMPEG_OPTS " -x 240 -w 2 -o "$MEDIA_TMP/$(basename "${file%.*}").mkv"
        if [[ $HAS_SUBS -eq 1 ]]
        then
            echo " [*  ] Adding Subtitles"
            ffmpeg -i "$file" -i "$MEDIA_TMP/$(basename "${file%.*}").mkv" -map 1:v -map 1:a -map 0:s -c:v copy -c:a copy -c:s copy -strict -2 "$MEDIA_TMP/$(basename "${file%.*}")-sub.mkv" &> /dev/null
            if [ $? -eq 1 ]
            then
                echo " [ * ] SUBTITLES ISSUE??? POSSIBLY CODEC 94213 RELATED! ATTEMPTING TO CONVERT TO SRT"
                ffmpeg -y -i "$file" -i "$MEDIA_TMP/$(basename "${file%.*}").mkv" -map 1:v -map 1:a -map 0:s -c:v copy -c:a copy -c:s srt -strict -2 "$MEDIA_TMP/$(basename "${file%.*}")-sub.mkv" &> /dev/null
                if [ $? -eq 1 ]
                then
                    echo " [  *] SUBS ARE COOKED! $file NO LONGER HAS SUBTITLES!" >> "$MEDIA_ROOT/subtitles.log"
                else
                    mv "$MEDIA_TMP/$(basename "${file%.*}")-sub.mkv" "$MEDIA_TMP/$(basename "${file%.*}").mkv"
                fi
            else
                mv "$MEDIA_TMP/$(basename "${file%.*}")-sub.mkv" "$MEDIA_TMP/$(basename "${file%.*}").mkv"
            fi
        fi
        echo " [*  ] Checking for file corruption"
        if ffmpeg -v error -i "$MEDIA_TMP/$(basename "${file%.*}").mkv" -f null -
        then
            echo " [*  ] File encoded, replacing now"
            mv "$MEDIA_TMP/$(basename "${file%.*}").mkv" "$file"
            mv "$file" "${file%.*}".mkv &> /dev/null  # Forces file to be mkv
            du -hs "${file%.*}".mkv >> "$MEDIA_ROOT/encode-size.log"
            echo " [*  ] Removing file from database"
            file_escaped=$(echo "$file" | sed "s/'/''/g")  # can't do ${var//foo/bar} for some reason, I might just be stupid
            sqlite3 "$DB_PATH/$DATABASE_NAME".db "DELETE FROM $ENCTABLE_NAME WHERE file = '$file_escaped'"
            continue
        else
            echo " [  *] FILE CORRUPTED! NOT REPLACING"
            echo "REVIEW $file" >> "$MEDIA_ROOT/error.log"
        fi
        echo " [*  ] Clearing encode cache"
        rm -rf "$MEDIA_ROOT/.encode_temp/$(basename "${file%.*}")"
    done
}

function cleanup() {
    echo " [*  ] All files now encoded. Please check logs for any issues."
    echo " [*  ] Cleaning up script"
    cd "$MEDIA_ROOT"
    rm -rf "$MEDIA_ROOT/.encode_temp"
    rm "$LOCKDIR/$ENCODER_LOCKFILE"
    exit 0
}

function ctrl_c() {
    echo " [  *] USER EXITING SCRIPT! CLEARING LOCK!"
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