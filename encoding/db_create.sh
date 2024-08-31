#!/bin/bash

# Version: 1.0.1

# Start date 2024-07-30
# Last Update 2024-08-31

# I got a shell checker :))
# shellcheck disable=2164 # that fucking cd || exit shit
# shellcheck disable=2317 # Unused code (trap ctrl_c screamed)

function vars() {
    # Variables that are set to make things work
    if ! [ -f media.env ]
    then
        echo " [  *] media.env not found, downloading example file"
        wget -O media.env "https://raw.githubusercontent.com/46620/Scripts/master/encoding/media.env.example"
    else
        source media.env
    fi
    # Optional, useful if you have a custom ffprobe build to speed up scan times (recommended)
    if [ -d TOOLS ]
    then
        echo " [*  ] TOOLS DIR FOUND! ADDING TO PATH"
        PATH=$(pwd)/TOOLS:$PATH
    fi
}

function create_db() {
    echo " [ * ] Making sure database exists."
    sqlite3 "$DB_PATH/$DATABASE_NAME".db "CREATE TABLE IF NOT EXISTS $ENCTABLE_NAME (file TEXT NOT NULL);"
}

function fill_db() {
    if [ -f "$LOCKDIR/$DB_LOCKFILE" ] # lock file check
        then
            echo " [ * ] LOCKFILE FOUND, DATABASE AGENT IS POSSIBLY RUNNING! IF IT'S NOT RUNNING PLEASE DELETE $LOCKDIR/$DB_LOCKFILE"
            exit 1
    fi
    mkdir -p "$LOCKDIR"
    touch "$LOCKDIR/$DB_LOCKFILE"
    readarray -d '' files_array < <(find "$MEDIA_ROOT" -type f -print0)
    readarray -t files_sorted < <(printf '%s\n' "${files_array[@]}" | sort)
    for file in "${files_sorted[@]}"
    do
        tracks=$(ffprobe "$file" |& grep -e "Stream.*Video" -e "Stream.*Audio" | wc -l) # If a file has both, it's safe to assume it's what we want.
        if [ "$tracks" -lt 2 ]
        then
            echo " [ * ] $file missing either audio or video track. Skipping" # This can have false positives
            continue # I didn't know this was a thing
        fi
        ffprobe "$file" |& grep "Video: av1" &> /dev/null
        if [ $? -eq 0 ] # Check if the file is av1.
        then
            #echo " [ * ] $file is AV1, don't put in database" # uncomment if you want to make sure the script it running without watching *top
            continue # file is AV1, do nothing
        fi
        echo " [ * ] $file is not AV1, put in database"
        file_escaped=$(echo "$file" | sed "s/'/''/g")
        file_stitched=$(echo "$file_escaped" | cut -c 1-)
        file_fixed=$(echo "$file_stitched" | sed "s@$MEDIA_ROOT/@@g")
        if [ "$(sqlite3 "$DB_PATH/$DATABASE_NAME".db "SELECT COUNT(*) FROM '$ENCTABLE_NAME' WHERE file = '$file_fixed';")" -gt 0 ]
        then
            echo " [ * ] File already in database"
            continue
        else
            sqlite3 "$DB_PATH/$DATABASE_NAME".db "INSERT INTO $ENCTABLE_NAME (file) VALUES('$file_fixed');"
        fi
    done
}

function remove_lock() {
    echo " [*  ] REMOVING LOCKFILE"
    rm "$LOCKDIR/$DB_LOCKFILE"
    exit
}

function main() {
    vars
    create_db
    fill_db
    remove_lock
}

main "$@"
