#!/bin/bash

# Start date 2025-04-10

# So this script will literally be my everything script for working on media. (except for encoding)
# Anytime I need to do something it will be added here.
# If you for some reason want to contribute, please send a PR.

# How script works #

# Script takes $1 as the function name and calls that function, it will then use the rest of the args as input
# If no arg is supplied, we tell the user all functions, and how to use them.

# Adding your own function #
#> If you for some reason want to add your own function, here are some notes
# Credit yourself if you want.
# If you use AI in your code, PLEASE specify so!
# Try to keep args consistent with other commands.
# Please try to keep any shellcheck warnings to a minimum. 
# If you don't want the user to call a function, either start it with an underscore, or embed it inside another function if you don't need to reuse it

# Shellcheck related shit #
# shellcheck disable=2164 # that fucking bird that I hate (cd || exit)


function help_menu() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
Usage: $program_name <function> [arg1] [arg2] ...
Functions:
    mkv-title <embed/restore> <path>        Embed filenames in files
    hash-all <path>                         Generate crc32 hashes and stores them in a text file
    setup                                   Installs all the programs that will be required

Info: It is recommended to run setup first, as it will install tools for ALL functions
      This script is always WIP, an updater will be added in the future
EOF
}

function _vars() {
    # Dump random vars you need set, give a comment or a useful name so we know what it does
    ulimit -n 20000 # Raises the amount of files that can be opened, fixes a lot of issues with large media sets
}

function _build_array() {
    readarray -d '' episodes_array < <(find "$MEDIA_ROOT" -type f -print0)
    readarray -t episodes_sorted < <(printf '%s\n' "${episodes_array[@]}" | sort)
}

function mkv-title() {
    # Usage:        Embed file name into video track "title" to allow restoring it later in case the file name gets fucked somehow
    # Added:        2025-04-10
    # Last Updated: 2025-04-10
    # AI usage:     No
    # $1 is mode
    # $2 is path
    _vars
    MODE="$1"
    MEDIA_ROOT="$2"
    if [ -z "$MODE" ]
    then
        echo " [  *] MODE IS NOT SET! PLEASE SELECT embed OR restore"
        exit 2
    fi
    if [ -z "$MEDIA_ROOT" ]
    then
        echo " [  *] MEDIA_ROOT IS NOT SET! PLEASE SET A FOLDER!"
        exit 2
    fi
    _build_array
    if [[ $MODE == "embed" ]]
    then
        for ep in "${episodes_sorted[@]}"
        do
            ep_name=$(basename "$ep")
            echo "[*  ] $ep_name"
            mkvpropedit "$ep" --edit info --set "title=${ep_name%.*}" > /dev/null 2>&1 &
        done
    elif [[ $MODE == "restore" ]]
    then
        for ep in "${episodes_sorted[@]}"
        do
            echo "[*  ] $(basename "$ep")"
            mv "$ep" "$(dirname "$ep")/$(ffprobe "$ep" |& grep "title" | head -n 1 | cut -b 23-).mkv"
        done
    else
        echo " [  *] MODE $MODE IS NOT AVAILABLE!"
        exit 128
    fi
}

function hash-all() {
    # Usage:        Create a text file with crc32 hashes of all files in a folder. Useful for open directories online :3
    # Added:        2025-04-10
    # Last Updated: 2025-04-10
    # AI Usage:     No
    # $1 is path
    echo " [*  ] Hashing all files, this may take a very long time."
    _vars
    MEDIA_ROOT="$1"
    if [ -z "$MEDIA_ROOT" ]
    then
        echo " [  *] MEDIA_ROOT IS NOT SET! PLEASE SET A FOLDER!"
        exit 2
    fi
    _build_array
    if [ -f "$MEDIA_ROOT/hashes.txt" ]
    then
        echo " [ * ] Moving hashes.txt to hashes-old.txt"
        mv "$MEDIA_ROOT/hashes.txt" "$MEDIA_ROOT/hashes-old.txt"
    fi
    for ep in "${episodes_sorted[@]}"
    do
        xxh32sum "$ep" >> "$MEDIA_ROOT/hashes.txt"
    done
}

function setup() {
    echo " [ * ] Installing dependencies"
    if [ -x "$(command -v pacman)" ]
    then
        sudo pacman -S mkvtoolnix-cli xxhash
    elif [ -x "$(command -v apt)" ]
    then
        sudo apt install mkvtoolnix xxhash
    else
        echo " [  *] Your current distro is not supported. Make a PR if you want support"
        exit 128
    fi
    echo " [*  ] Dependencies installed! Please rerun the script."
    exit 0
}

function main() {
    if [ -z "$1" ]
    then
        help_menu
    fi
    args=("$@") # Sets args to all args provided by the user
    fun="$1" # set fun(ction) to the first arg
    for target in "${fun[@]}" # stolen from stackoverflow 16860877
    do
        for i in "${!args[@]}"
        do
            if [[ ${args[i]} = "$target" ]]
            then
                unset 'args[i]' # Removes $fun from $args to allow us to start from $1 when dealing with user input
            fi
        done
    done
    if [[ "${fun:0:1}" == "_" ]]
    then
        echo " [  *] Please do not try to call any function with _"
        exit 128
    fi
    $fun "${args[@]}"
}

main "$@"