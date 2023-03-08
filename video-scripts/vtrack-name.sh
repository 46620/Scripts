#!/bin/bash

# set file limit up in case I merge this with my AV1 encoding script, get full path of all mkv files in sub directories (strip the extension), and sort them A-Z
ulimit -n 200000
script_home=`pwd`
readarray -d '' files_array < <(find . -name "*.mkv" | sed 's@.mkv@@g');
IFS=$'\n' files_sorted=($(sort <<<"${files_array[*]}"))
unset IFS

# echo file name, cd into folder, edit the video track name, cd back out, repeat
for video in "${files_sorted[@]}"
do
    echo "`basename "$file"`"
    cd "`dirname "$file"`"
    mkvpropedit "`basename "$file.mkv"`" -d title
    mkvpropedit "`basename "$file.mkv"`" -a title="`basename "$file"`"
    cd "$script_home"
done