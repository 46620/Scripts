#!/bin/bash

#set -x
ulimit -n 20000
readarray -d '' files_array < <(find . -iname "*.mkv" | sed 's/.mkv//g')
readarray -t files_sorted < <(printf '%s\n' "${files_array[@]}" | sort)

# Store file names
function store() {
        for ep in "${files_sorted[@]}"
        do
            ep2=$(basename "$ep")
            echo "[ * ] $ep2"
            mkvpropedit "$ep.mkv" --edit info --set "title=$ep2" > /dev/null 2>&1 &
        done
}

# Restore file names
function fix() {
        echo " [ * ] Fixing files. This will take a while."
        for ep in "${files_sorted[@]}"
        do
            echo "[ * ] $(basename "$ep")"
            mv "$ep.mkv" "$(dirname "$ep")/$(ffprobe "$ep".mkv |& grep "title" | cut -b 23- | head -n 1).mkv"
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
