#!/bin/bash

# Why

# Set this to a folder where all of the ISOs are stored
ISO_ROOT=

cd "$ISO_ROOT"
readarray -d '' files_array < <(find . -name "*.iso" | sed 's@.iso@@g');
IFS=$'\n' files_sorted=($(sort <<<"${files_array[*]}"))
unset IFS

for iso in "${files_sorted[@]}"
do
    echo "$iso"
    iso2=`basename "$iso"`
    cd "`dirname "$iso"`"
    extract-xiso "$iso2.iso"
    7z a "$iso.7z" "$iso"
    cd "$ISO_ROOT"
done