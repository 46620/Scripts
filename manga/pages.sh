#!/bin/bash

# I hate my fucking life
# Why can't I do this with a premade script already why am I making this just to delete it.
# MIA FUCKING DONT DELETE ME

mapfile -t PAGES < <(find . -type f -name "*.png" | sort)
PAGE_COUNT="${#PAGES[@]}"
PAD_WIDTH=${#PAGE_COUNT}
echo "$PAGE_COUNT"

mkdir output

for page in $(seq -w 0 $(("$PAGE_COUNT" - 1)))
do
    COUNTER=$((10#$page + 1))  # make sure that bash arrays stay in sync
    COUNTER=$(printf "%0${PAD_WIDTH}d" "$COUNTER")  # Padding is needed
    echo "${PAGES[10#$page]}"
    echo "$page" "$COUNTER"
    cp -v "${PAGES[10#$page]}" "output/$COUNTER.png"
done
