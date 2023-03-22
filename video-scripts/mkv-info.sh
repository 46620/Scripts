#!/bin/bash

# set file limit up in case I merge this with my AV1 encoding script, get full path of all mkv files in sub directories (strip the extension), and sort them A-Z
ulimit -n 200000
script_home=`pwd`
readarray -d '' files_array < <(find . -name "*.mkv" | sed 's@.mkv@@g');
IFS=$'\n' files_sorted=($(sort <<<"${files_array[*]}"))
unset IFS

# echo file name, cd into folder, edits some metadata, cd back out, repeat
for video in "${files_sorted[@]}"
do
    echo "`basename "$video"`"
    cd "`dirname "$video"`"
    mkvpropedit "`basename "$video.mkv"`" --edit info --set title="`basename "$video"`" --edit track:v1 --set language=jpn
    cd "$script_home"
done