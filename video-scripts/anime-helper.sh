#!/bin/bash

# Script name: anime-helper.sh
# Desc: Anidb metadata agent written in bash
# Start Date: 2023-10-30
version=20250721 # Last updated date YYYYMMDD
function usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
$program_name v$version
Usage: $program_name <-i /path/to/show> <-n #> <-s ##>
Options:
    -h               Prints this message
    -d               Install dependencies
    -i               Season path
    -n               AniDB ID of the show
    -s               Season number. Please pad (eg: 01, 02)

Note: Currently this is only meant for one season at a time, please do not try to use it against your entire library.
EOF
}

function install_deps() {
    echo " [ * ] Installing dependencies"
    if [ -x "$(command -v pacman)" ]
    then
        sudo pacman -S curl mkvtoolnix-cli xmlstarlet
    elif [ -x "$(command -v apk)" ]
    then
        sudo apk add curl mkvtoolnix xmlstarlet
    elif [ -x "$(command -v apt)" ]
    then
        sudo apt install curl mkvtoolnix xmlstarlet
    elif [ -x "$(command -v dnf)" ]
    then
        sudo dnf install curl mkvtoolnix xmlstarlet
    elif [ -x "$(command -v zypper)" ]
    then
        sudo zypper install curl mkvtoolnix xmlstarlet
    else
        echo " [  *] Your current distro is not supported. Make a PR if you want support" # Gentoo users are not supported because I am NOT figuring out the fucking emerge packages.
    fi
    echo " [*  ] Dependencies installed! Please rerun the script without -d to actually use it."
}

function vars() {
    echo " [*  ] Setting variables"
    readonly ANIDB_CLIENT_NAME=farris
    readonly ANIDB_CLIENT_VER=1
    readonly CACHE="$HOME/.local/share/46620/anime-helper/cache/"
    readonly META_URL_BASE="http://api.anidb.net:9001/httpapi?client=$ANIDB_CLIENT_NAME&clientver=$ANIDB_CLIENT_VER&protover=1&request=anime&aid="
    readonly IMG_URL_BASE="https://cdn-us.anidb.net/images/main/"
    CURRENT_TIME=$(date +%s)
    COUNTER=0
}

# This is to try to prevent a ban from anidb, as their API is very strict
function cache() {
    echo " [*  ] Checking API limit"
    CURRENT_API_USAGE=$(cat "$CACHE/api-limiter")
    if [ $? -eq 1 ]; then CURRENT_API_USAGE=0; fi # If the file doesn't exist, set 0
    if [ "$CURRENT_API_USAGE" -lt "15" ]
    then
        echo " [*  ] API limit not reached yet"
        CURRENT_API_USAGE=$((CURRENT_API_USAGE+1))
        echo "$CURRENT_API_USAGE" > "$CACHE/api-limiter"
    else
        echo " [ * ] Checking if it's safe to contact AniDB"
        TIME_SINCE_FIRST_API_CALL=$(stat -c %W "$CACHE/api-limiter") # Check time the file was created, this would line up with the first API call made. This has several flaws. First being if the user does 1 call and then 23 hours and 59 minutes later does 15 more, there is a chance they will get banned. Second is that we should do this before checking if the limit has been hit. Third being none of this was tested because I got banned before this code was written and currently can't test.
        if [ $(("$CURRENT_TIME"-"$TIME_SINCE_FIRST_API_CALL")) -lt "86400" ]
        then
            echo "[  *] Possible ban risk, please try again in 24 hours"
            exit 1
        else
            echo " [*  ] You should be fine, please open a bug report if you get temp banned."
            rm "$CACHE/api-limiter" # Resets the file birth time, which is what is used above
            echo "1" > "$CACHE/api-limiter"
        fi
    fi

    echo " [*  ] Checking Cache"
    mkdir -p "$CACHE/$SHOW_ID"
    LAST_MODIFIED=$(stat -c %Y "$CACHE/$SHOW_ID/data.xml" 2>/dev/null) # Check cache time
    if [ $? -eq 1 ]; then LAST_MODIFIED=0; fi
    if [ $(("$CURRENT_TIME"-"$LAST_MODIFIED")) -lt "604800" ] # Cache is valid for 7 days, this might get lowered to 48 hours.
    then
        echo " [*  ] Cache is new enough, not updating"
    else
        echo " [ * ] Updating cache"
        curl -sH 'Accept-encoding: gzip' "$META_URL_BASE$SHOW_ID" | gunzip - > "$CACHE/$SHOW_ID/data.xml"
        curl -o "$CACHE/$SHOW_ID/cover.jpg" $IMG_URL_BASE"$(xmlstarlet sel -t -v '//picture' "$CACHE"/"$SHOW_ID"/data.xml | head -1)"
        echo " [*  ] Cache updated"
    fi
}

function parse() {
    # This function is mostly done by ChatGPT, as I do not understand xmlstarlet at all
    echo " [*  ] Parsing xml"

    echo " [*  ] Getting episode count"
    EPISODE_COUNT=$(xmlstarlet sel -t -v '//episodecount' "$CACHE"/"$SHOW_ID"/data.xml)

    echo " [*  ] Getting episode names"
    EPISODE_NAMES=()
    while IFS= read -r line; do
        EPISODE_NAMES+=("$line")
    done < <(xmlstarlet sel -t -m '//episode/epno[@type="1"]' -v "format-number(., '0000')" -o ' ' -v '../title[@xml:lang="en"]' -n "$CACHE/$SHOW_ID/data.xml" | sort | cut -b 6- | sed "s@\`@'@g")

    echo " [*  ] Getting air dates"
    AIR_DATE=()
    while IFS= read -r line; do
        AIR_DATE+=("$line")
    done < <(xmlstarlet sel -t -m '//episode/epno[@type="1"]' -v "format-number(., '0000')" -o ' ' -v '../airdate' -n "$CACHE/$SHOW_ID/data.xml" | sort | cut -b 6- | sed "s@\`@'@g")

    echo " [*  ] Getting Show name"
    SHOW_NAME=$(xmlstarlet sel -t -v '//title[@type="main"]' "$CACHE"/"$SHOW_ID"/data.xml)

    # xmlstart command gets all non special episodes, pads the number out to 4 digits, sorts them 0-9, then strips the numbers out, then replaces tildes with a single quote
    # I do plan to rewrite this without AI at some point, but for now this code works.
}

function build_array() {
    readarray -d '' episodes_array < <(find "$SHOW_PATH" -mindepth 1 -maxdepth 1 -type f -print0)
    readarray -t episodes_sorted < <(printf '%s\n' "${episodes_array[@]}" | sort)
}

function rename() {
    echo " [*  ] Quickly building episode array"
    build_array

    echo " [*  ] Renaming episodes"
    for EPISODE in $(seq -w 0 $(("$EPISODE_COUNT" - 1)))
    do
        EPISODE_NUM=$(( 10#$EPISODE+1 )) # Bash starts at 0, shows start at 1, I need them to match
        EPISODE_NUM_LEN=${#EPISODE_NUM} # This is to deal with padding below
        PADDING_REQ=$((${#EPISODE_COUNT}-"$EPISODE_NUM_LEN")) # Subtract len of episodes by len of the current episode number
        PADDING=$(head -c "$PADDING_REQ" /dev/zero | tr '\0' '0') # Create the zeros for padding
        mv -v "${episodes_sorted[10#$EPISODE]}" "$SHOW_PATH"/"$SHOW_NAME"\ -\ S"$SEASON_NUMBER"E"$PADDING""$EPISODE_NUM"\ -\ "${EPISODE_NAMES[10#$EPISODE]}".mkv # Renname the episodes
    done
}

function metadata() {
    # Embeds "SHOW NAME - S#E# - EPISODE NAME" into the title, sets the date the episode aired, and then embeds the show cover into the file.
    echo " [*  ] Embedding episode names"
    build_array
    for EPISODE in "${episodes_sorted[@]}"
    do   
        EPISODE_BASE=$(basename "$EPISODE")
        echo " [*  ] $EPISODE_BASE"
        mkvpropedit "$EPISODE" --edit info \
                               --set "title=${EPISODE_BASE%.*}" \
                               --set "date=${AIR_DATE[$COUNTER]}T00:00:00+00:00" \
                               --attachment-name "cover" --attachment-mime-type "image/jpeg" --add-attachment "$CACHE"/"$SHOW_ID"/cover.jpg > /dev/null 2>&1
        COUNTER=$((COUNTER+1))
    done
    # TODO: Find out if another metadata source has air times and add to the time above
}

function main() {
    vars
    cache
    parse
    rename
    metadata
}

function prep() {
    if [ $# -eq 0 ];then usage;exit 1;fi
    while getopts ":i:n:s:dh" prep
    do
        case $prep in
            i)
                if [ -d "$OPTARG" ]
                then
                    SHOW_PATH="$OPTARG"
                else
                    usage
                    exit 1
                fi
                ;; # SHOW_PATH
            n)
                numbers='^[0-9]+$'
                if ! [[ $OPTARG =~ $numbers ]]
                then
                    usage
                    exit 1
                else
                    SHOW_ID="$OPTARG" # TODO: Work on show name parser to make this step optional
                fi
                ;; # SHOW_ID
            s)
                numbers='^[0-9]+$'
                if ! [[ $OPTARG =~ $numbers ]]
                then
                    usage
                    exit 1
                else
                    SEASON_NUMBER="$OPTARG"
                fi
                ;; # SEASON_NUMBER
            d)
                install_deps
                exit 0
                ;;
            h|\?|:|*)
                usage
                exit 0
                ;;
        esac
    done
    shift $((OPTIND - 1))
    if [ -z "$SHOW_PATH" ] || [ -z "$SHOW_ID" ]; then
        usage
        exit 1
    fi
    main
}

prep "$@"