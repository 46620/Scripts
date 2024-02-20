#!/bin/bash

# I hate my fucking life
# This script is used to repack the PS3 library archives from GGn
# This takes the existing 7z files, extracting the ISOs out of them, decrypting, unpacking, and repacking the ISOs a folder inside a 7z archive, ready for use with RPCS3. You could also sit and repack to run on a PS3, but that's not the goal of this script.
# I attempted to rewrite this once and it actually caused more issues than it fixed, so we're going to continue with this old version


readonly GAME_PATH=

ulimit -n 20000
readarray -d '' PS3 < <(find "$GAME_PATH" -iname "*.7z" -print0)
unset IFS

mkdir -p tmp

for cum in "${PS3[@]}"
do
    7zz e "${cum}" # Extracts 7z
    libray -i "${cum%??}"iso # Decrypt the iso
    if ! [ $? -eq 0 ] # logs ISO's that don
    then
        echo "[ * ] ${cum} IS EITHER CORRUPTED OR NO IRD FOUND! PLEASE MANUALLY CHECK" > /mnt/android/PS3/log.log
        rm "${cum%??}"iso
        continue
    fi
    rm "${cum%??}"iso # Delete encrypted iso
    mv *.iso "${cum%??}"iso # Idk how to dynamically grab a file name and wildcards don't work here so do this
    7zz x -o"${cum%???}" "${cum%??}"iso # Extract decrypted iso
    rm "${cum%??}"iso # bye-bye iso
    7zz a -mx=9 -mfb=64 -md=32m -ms=on tmp/"${cum}" "${cum%???}" # Compress the fuck outta this
    rm -rf "${cum%???}" # Fuck you temp folder
done