#!/bin/bash

#set -x
set -e
cd Anime
folders=( "$D"* )

for cum in "${folders[@]}"
do
    cd "$cum"
    folders2=()
    folders2=( "$D"* )
    for cum2 in "${folders2[@]}"
    do
        cd "$cum2"
        mkdir tmp
        files=()
            while IFS=  read -r -d $'\0'; do
            files+=("$REPLY")
            done < <(find . -iname "*.mkv" -print0 | sed 's@./@@g' | sed 's/.mkv//g')
        echo "${files[@]}"
        for cum in "${files[@]}"
            do
                echo $cum
                ffmpeg -i "$cum.mkv" -map 0 -c copy -metadata:s:v:0 title="$cum" "tmp/$cum.mkv"
            done
        mv tmp/* .
        rm -r tmp
        cd ..
    done
    cd ..
done