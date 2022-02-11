#!/bin/bash

# this is mostly to change file hashes so they're slightly different from any public file

files=()
while IFS=  read -r -d $'\0'; do
    files+=("$REPLY")
done < <(find . -iname "*.mkv" -print0 | sed 's@./@@g' | sed 's/.mkv//g')

for cum in "${files[@]}"
do
    echo $cum
done