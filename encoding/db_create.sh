#!/bin/bash

# Start date 2024-07-30
# Version 20251101

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
        PATH="$(pwd)/TOOLS:$PATH"
    fi
}

function create_db() {
    echo " [ * ] Making sure database exists."
    sqlite3 "$DB_PATH/$DATABASE_NAME".db "CREATE TABLE IF NOT EXISTS $ENCTABLE_NAME (file TEXT NOT NULL);"
}

function fill_db() {
    if [ -f "$LOCKDIR/$DB_LOCKFILE" ]  # lock file check
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
        tracks=$(ffprobe "$file" |& grep -c -e "Stream.*Video" -e "Stream.*Audio")  # If a file has both, it's safe to assume it's a video file with audio.
        if [ "$tracks" -lt 2 ]
        then
            echo " [ * ] $file might not be a video file, skipping for now."
            continue
        fi
        if ffprobe "$file" |& grep -q "Video: av1"
        then
            echo " [ * ] $file is already AV1, skipping"
            continue
        fi
        echo " [ * ] $file is not AV1, put in database"
        file_escaped=$(echo "$file" | sed "s/'/''/g")
        file_stitched=$(echo "$file_escaped" | cut -c 1-)
        file_fixed=${file_stitched//$MEDIA_ROOT\//}
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
