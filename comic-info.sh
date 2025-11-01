#!/bin/bash
#set -x

# Script name: comic-info.sh
# Desc: ComicInfo.xml creator in bash.
#       Useful for when scraping/creating a .cbz yourself and need metadata
# Start Date: 2025-06-30
version=20250709 # Last updated date YYYYMMDD, days being XX usually means beta I hope to finish in the month
function usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
$program_name v$version
Usage: $program_name <-i /path/to/files.cbz> <-n #> [-t translation group]
Options:
    -h                  Prints this message
    -d                  Install dependencies
    -i                  /path/to/files.cbz (Required)
    -n                  AniList ID for the manga (Required)
    -t                  Translation Group (Default: N/A)

Note: Currently this is script is meant for Volumes only!
EOF
}

function install_deps() {
    echo " [ * ] Installing dependencies"
    if [ -x "$(command -v pacman)" ]
    then
        sudo pacman -S curl jq xmlstarlet zip
    elif [ -x "$(command -v apk)" ]
    then
        sudo apk add curl jq xmlstarlet zip
    elif [ -x "$(command -v apt)" ]
    then
        sudo apt install curl jq xmlstarlet zip
    elif [ -x "$(command -v dnf)" ]
    then
        sudo dnf install curl jq xmlstarlet zip
    elif [ -x "$(command -v zypper)" ]
    then
        sudo zypper install curl jq xmlstarlet zip
    else
        echo " [  *] Your current distro is not supported. Make a PR if you want support" # This will most likely just be gentoo users, I am NOT dealing with them right now.
    fi
    echo " [*  ] Dependencies installed! Please rerun the script without -d to actually use it."
}

function vars() {
    readonly CACHE="$HOME/.local/share/46620/comic-info/cache"
    CURRENT_TIME=$(date +%s)
    COUNTER=0
    EXP_USE_RENAMER=0 # This will rename files to "$SERIES_NAME - Vol $VOL_NUM. [$TRANSLATOR].cbz". This will also renamed the "$MANGA_PATH", hence why it'll stay as EXP
}

function cache() {
    # We cache everything pulled, and the cache is marked as old after 24 hours, allowing you to repull the data
    echo "[*  ] Checking cache"
    mkdir -p "$CACHE/$MANGA_ID" # It doesn't break anything to make it every time, and it's shorter to do it this way
    LAST_MODIFIED=$(stat -c %Y "$CACHE/$MANGA_ID/data.json" 2>/dev/null) # Check cache time
    if [ $? -eq 1 ]; then LAST_MODIFIED=0; fi # If the file doesn't exist, set 0 to force update
    if [ $(("$CURRENT_TIME"-"$LAST_MODIFIED")) -lt "86400" ] # See comment about about rate limit
    then
        echo " [*  ] Cache is new enough, not updating."
    else
        echo " [ * ] Updating cache"
        # This will grab everything for a ComicInfo.xml besides the Translator. I prefer to set the scan group that did it, unless someone uploaded the official translation
        curl -sS -X POST https://graphql.anilist.co -H "Content-Type: application/json" \
            -d "{
            \"query\": \"query (\$id: Int){ \
                Media(id: \$id, type: MANGA) { \
                    id \
                    title { romaji english } \
                    volumes \
                    description \
                    staff { edges { role node { name { full }}}} \
                    genres \
                    countryOfOrigin \
                    status \
                    } \
                }\",
                \"variables\": { \"id\": $MANGA_ID }
            }" -o "$CACHE/$MANGA_ID/data-tmp.json"
        if [ "$(jq -r ".data.Media.id" "$CACHE/$MANGA_ID/data-tmp.json")" -eq "$MANGA_ID" ]
        then
            echo " [*  ] Cache updated"
            mv "$CACHE/$MANGA_ID/data-tmp.json" "$CACHE/$MANGA_ID/data.json"
        else
            echo " [  *] Anilist did not return the correct data! Below is the file returned."
            echo "$CACHE/$MANGA_ID/data-tmp.json"
            exit 1
        fi
    fi
}

function create_template() {
    # This function stayed cleaner than I expected because I put on my big girl thinking cap and now we have this failed abortion of a function. oops
    echo " [*  ] Creating template xml file from data"
    SERIES_NAME=$(jq -r ".data.Media.title | to_entries[0].value" "$CACHE/$MANGA_ID/data.json") # We use the Romanji name to stay consistent with other sources
    SUMMARY=$(jq -r ".data.Media.description" "$CACHE/$MANGA_ID/data.json" | sed 's/<[^>]*>//g') # Need to strip out HTML tags that get left behind. Hopefully no manga uses them for any part of the description.
    WRITER=$(jq -r '.data.Media.staff.edges[] | select(.role == "Story & Art") | .node.name.full' "$CACHE/$MANGA_ID/data.json") # From my testing I haven't come across a series that doesn't have "Story & Art" as the same person, if that happens please submit an issue with the series so I can fix this.
    PENCILLER=$WRITER # For most series I've worked with, they're the same person so I will just assume that to be the case.
    GENRE=$(jq -r .data.Media.genres[] "$CACHE/$MANGA_ID/data.json" | sed '{:q;N;s/\n/, /g;t q}')

    cat <<EOF > "$CACHE/$MANGA_ID/ComicInfo.xml" # The only thing not filled in is %VOL_NUM%, as we set that when we are putting shit into files
<?xml version='1.0' encoding='UTF-8' ?>
<ComicInfo xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Title>Vol. %VOL_NUM%</Title>
  <Series>$SERIES_NAME</Series>
  <Number>%VOL_NUM%</Number>
  <Summary>$SUMMARY</Summary>
  <Writer>$WRITER</Writer>
  <Penciller>$PENCILLER</Penciller>
  <Translator>$TRANSLATOR</Translator>
  <Manga>YesAndRightToLeft</Manga>
  <Genre>$GENRE</Genre>
  <Web>https://anilist.co/manga/$MANGA_ID</Web>
</ComicInfo>
EOF
}

function metadata() {
    echo " [*  ] Adding metadata to .cbz files"
    LOCAL_VOL_COUNT=$(find "$MANGA_PATH" -type f -name "*.cbz" | wc -l) # This is the volumes locally stored, useful in case you don't have every volume downloaded
    mapfile -t LOCAL_VOL_ORDER < <(find "$MANGA_PATH" -type f -name "*.cbz" | sort) # Put file in A-Z order. oh yeah that was a requirement for this to work correctly if you didn't know.

    for xml in $(seq -w 0 $(("$LOCAL_VOL_COUNT" - 1)))
    do
        basename "${LOCAL_VOL_ORDER[10#$xml]}"
        COUNTER=$(( 10#$xml+1 ))
        if [ ${#COUNTER} -eq 1 ]; then COUNTER=0"$COUNTER"; fi # Yet another hacky workaround i refuse to learn printf
        xmlstarlet ed -u "/ComicInfo/Title" -v "Vol. $COUNTER" -u "/ComicInfo/Number" -v "$COUNTER" "$CACHE/$MANGA_ID/ComicInfo.xml" > /tmp/ComicInfo.xml # Change Title and Number tag (I wanted to use sed, already wrote this though)
        zip -qju "${LOCAL_VOL_ORDER[10#$xml]}" /tmp/ComicInfo.xml
    done
}

function rename() {
    echo " [** ] Checking if renamer was enabled"
    if [ $EXP_USE_RENAMER -eq 0 ]
    then
        cleanup
    else
        echo " [ * ] Running renamer! Please note that this code is slightly experimental!!"
        # I lied, it's very stable but I don't feel like testing it much so I'm going to say experimental
        mapfile -t LOCAL_VOL_ORDER < <(find "$MANGA_PATH" -type f -name "*.cbz" | sort) # I am remaking the array just for safety, it shouldn't have changed but I don't trust the user
        COUNTER=0 # This needs to be reset
        for file in $(seq -w 0 $(("$LOCAL_VOL_COUNT" - 1)))
        do
            COUNTER=$(( 10#$file+1 ))
            if [ ${#COUNTER} -eq 1 ]; then COUNTER=0"$COUNTER"; fi # Yet another hacky workaround i refuse to learn printf
            mv -v "${LOCAL_VOL_ORDER[10#$file]}" "$MANGA_PATH/$SERIES_NAME - Vol $COUNTER. [$TRANSLATOR].cbz"
        done
        mv -v "$MANGA_PATH" "$(dirname "$MANGA_PATH")/$SERIES_NAME"
    fi
}

function cleanup() {
    echo "[*  ] Files have been modified! Cleaning up tmp files"
    rm /tmp/ComicInfo.xml
    exit 0
}

function main() {
    vars
    cache
    create_template # This was planned to only be called by cache, but if someone fucked up typing the scan group name, it wouldn't let you update it for 24h.
    metadata
    rename
    cleanup
}

function prep() {
    if [ $# -eq 0 ];then usage;exit 1;fi
    while getopts ":i:n:t:dh" prep
    do
        case $prep in
            i)
                if [ -d "$OPTARG" ]
                then
                    MANGA_PATH="$OPTARG"
                else
                    usage
                fi
                ;;
            n)
                numbers='^[0-9]+$'
                if ! [[ $OPTARG =~ $numbers ]]
                then
                    usage
                else
                    MANGA_ID="$OPTARG"
                fi
                ;;
            t)
                TRANSLATOR=${OPTARG:-"N/A"}
                ;;
            d)
                install_deps
                ;;
            h|\?|:|*)
                usage
                exit 0
                ;;
        esac
    done
    shift $((OPTIND - 1))
    if [ -z "$MANGA_PATH" ] || [ -z "$MANGA_ID" ]; then
        usage
        exit 1
    fi
    main
}

# MANGA_PATH=i
# MANGA_ID=n
# TRANSLATOR=t

prep "$@"