#!/bin/bash

# set file limit up in case I merge this with my AV1 encoding script, get full path of all mkv files in sub directories (strip the extension), and sort them A-Z
ulimit -n 200000
script_home=`pwd`
readarray -d '' files_array < <(find . -name "*.mkv" | sed 's@.mkv@@g');
IFS=$'\n' files_sorted=($(sort <<<"${files_array[*]}"))
unset IFS

# echo file name, cd into folder, edit the video track name, cd back out, repeat
for cum in "${files_sorted[@]}"
do
    echo "`basename "$cum"`"
    cd "`dirname "$cum"`"
    mkvpropedit "`basename "$cum.mkv"`" -d title
    mkvpropedit "`basename "$cum.mkv"`" -a title="`basename "$cum"`"
    cd "$script_home"
done