#!/bin/bash

# This scripts entire plan is to make a semi usable replacement to filebots renaming functions in just bash
# This script will only be for anime, as I do not feel like fucking with tvdb right now.

# Start date: 2023-01-13

# set -x

usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
Usage: $program_name [--option]
Options:
    --help          Print this message
    --gendb         Downloads database files for the script
    --rename        Rename (not implemented yet)
    --update        Updates the script to the latest

Info: All data for the script is stored in $HOME/.local/share/46620/metadata/
EOF
}

# This checks if the script is running for the first time.
config() {
    if [[ ! -d "$HOME/.local/share/46620/metadata/" ]]; then
        echo "* Creating config folder"
        mkdir -p "$HOME/.local/share/46620/metadata/"
        touch "$HOME/.local/share/46620/metadata/update"
        echo "last_updated=$EPOCHSECONDS" > $HOME/.local/share/46620/metadata/update
    fi
}

# Checks when the database was last pulled, if over a day, pull the db, and gunzip it
anidb_db_downloader() {
    echo "* Checking anidb database"
    if [[ -f "$HOME/.local/share/46620/metadata/anime-titles.xml" ]]; then
        source "$HOME/.local/share/46620/metadata/update"
        timer=`echo "$EPOCHSECONDS-$last_updated" | bc`
        if [[ ! $timer -ge 86400 ]]; then
            echo "* Database has been synced within the last 24 hours, please try again later to prevent getting banned from AniDB"
        else
            echo "* Downloading anidb database"
            wget -O "$HOME/.local/share/46620/metadata/anime-titles.xml.gz" http://anidb.net/api/anime-titles.xml.gz
            echo "* Extracting database"
            gunzip "$HOME/.local/share/46620/metadata/anime-titles.xml.gz"
            echo "last_updated=$timer" > $HOME/.local/share/46620/metadata/update
            echo "* Database extracted and ready for use"
        fi
    else 
        echo "* Fucking something broke somehow, rerun the script with the set -x line uncommented and give me a log"
        exit 1
    fi
}

# makes sure the script has a data location, then download the metadata databases that will be used
metadata_gendb() {
    config
    anidb_db_downloader
}

script_update() {
    local program_name
    program_name=${0##*/}
	clear
	echo "Updating the script please wait..."
	sleep 1
	SCRIPT_PATH="`dirname \"$0\"`"
	wget -O "$SCRIPT_PATH/$program_name" "https://raw.githubusercontent.com/46620/Scripts/master/metadata/metadata.sh"
	exit 0
}

main() {
    
    case "$1" in
        ''|-h|--help)
            usage
            exit 0
            ;;
        --gendb)
            metadata_gendb
            ;;
        --update)
            script_update
            ;;
        *)
            echo "Command not found" >&2
            exit 1
    esac
}

main "$@"