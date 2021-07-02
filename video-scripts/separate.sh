#!/bin/bash
#Takes file, chapters, and optional flags and will run on the file
#This script is meant for making a BD file not a single file
# ./separate.sh <file> <chapter file> [flags]
# Example: ./separate.sh Beyblade.mkv chapters.txt

if [ $# -lt 2 ];
   then
   printf "Not enough arguments.\n./separate.sh <file> <chapter file> [flags]\n" $#
   exit 0
   fi

chapters=( `cat $2` )
filename="${1%.*}"
flags=${3:-}
for c in "${chapters[@]}"
do
  HandBrakeCLI -i "$1" -c $c $flags -o "$filename - $c.mkv"
done