#!/bin/bash

#set -x
ulimit -n 20000
readarray -d '' files_array < <(find . -iname "*.mkv" | sed 's/.mkv//g')
IFS=$'\n' files_sorted=($(sort <<<"${files_array[*]}"))
unset IFS

# Store file names
function store() {
        for ep in "${files_sorted[@]}"
        do
                ep2=`basename "$ep"`
                echo " [ * ] `basename "$ep"`"
                mkvpropedit "$ep.mkv" --edit info --set "title=$ep2" > /dev/null 2>&1 &
        done
}

# Restore file names
function fix() {
        echo " [ * ] Fixing files. This will take a while. (Nothing will be outputted to the screen unless set -x is uncommented)"
        for ep in "${files_sorted[@]}"
        do
                mv "$ep.mkv" "`dirname "$ep"`/`ffprobe "$ep".mkv |& grep "title" | cut -b 23- | head -n 1`.mkv"
        done
}

main() {
    case "$1" in
        '')
            store
            ;;
        --fix)
            fix
            ;;
        *)
            echo "Command not found" >&2
            exit 1
    esac
}

main "$@"
