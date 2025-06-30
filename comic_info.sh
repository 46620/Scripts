#!/bin/bash
#set -x
# comic_info
# Automate setting ComicInfo.xml files so I can be lazy with uploading manga
# Start Date:   2025-06-30
# Last Update:  2025-06-30

# TODO:
#       Add AniDB API shit to pull ALL information automatically
#       Make cleaner
#       Clean up all hacky workarounds

vol_count=$(find . -type f -name "*.cbz" | wc -l)

for vol in $(seq -w 0 "$vol_count")
do
    if [ "$vol" -eq 0 ];then continue; fi # array starts at zero i need 1 blah blah WHO GAF!!!
    xmlstarlet ed -u "/ComicInfo/Title" -v "Vol. $vol" -u "/ComicInfo/Number" -v "$vol_count" ComicInfo.xml > ComicInfo-"$vol".xml # Change Title and 'Chapter' number
done

mapfile -t vol_order < <(find . -type f -name "*.cbz" | sort)
#mapfile -t xml_order < <(find . -type f -name "*.xml" | sort) # This WILL grab ComicInfo.xml, it's fine it'll throw an error anyways (Will fix in cleanup) (This ended up being unused... oops :3)

for xml in $(seq -w 0 "$vol_count")
do
    COUNTER=$(( 10#$xml+1 )) # See line 14 comment
    if [ ${#COUNTER} -eq 1 ]; then COUNTER=$(echo 0$COUNTER); fi # Yet another hacky workaround i refuse to learn printf
    echo "$COUNTER"
    # Uncomment the next 2 lines to keep track of what is happening
    #echo "${vol_order[10#$xml]}"
    #echo "${xml_order[10#$xml]}"
    mv ComicInfo.xml ComicInfo.xml.bak # Backup original in case it's a template file
    mv ComicInfo-"$COUNTER".xml ComicInfo.xml
    zip -u "${vol_order[10#$xml]}" ComicInfo.xml
done
