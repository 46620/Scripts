#!/bin/bash

# set -x

# Script name: anime-helper.sh
# Desc: Anidb metadata agent written in bash
# Date: 2023-10-30
# Mod : 2025-01-26

# I got a shell checker :))
# shellcheck disable=2164 # that fucking "cd || exit" shit that I hate

function usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
$program_name v0.0.1-legit
Usage: $program_name <-i /path/to/show> <-n #> <-s ##>
Options:
    -h               Prints this message
    -d               Install dependencies
    -i               Season path
    -n               AniDB ID of the show (currently we don't autodetect that)
    -s               Season number. Please pad (eg: 01, 02)

Note: Currently this is only meant for one season at a time, please do not try to use it against your entire library.
EOF
}


function install_deps() { # Do this last
    echo " [ * ] Installing dependencies"
    if [ -x "$(command -v pacman)" ]
    then
        sudo pacman -S curl bc mkvtoolnix-cli xmlstarlet
    elif [ -x "$(command -v apk)" ]
    then
        sudo apk add curl bc mkvtoolnix xmlstarlet
    elif [ -x "$(command -v apt)" ]
    then
        sudo apt install curl bc mkvtoolnix xmlstarlet
    elif [ -x "$(command -v dnf)" ]
    then
        echo " [  *] Sorry, I don't support Fedora currently."
    fi
    echo " [*  ] Dependencies installed! Please rerun the script without -d to actually use it."
    # TODO: FIND A CLEAN WAY TO DO THIS
    # curl
    # bc
    # mkvtoolnix-cli
    # xmlstarlet
}

function vars() {
    # You may be thinking: Mia, why is this a function? Well first, why the fuck are you thinking that? Second, fuck you, my code :3
    echo " [*  ] Setting variables"
    readonly CLIENT_NAME=farris # anidb client
    readonly CLIENT_VER=1 # anidb client version
    readonly CACHE="$HOME/.local/share/46620/anime-helper/cache/"
    readonly META_URL_BASE="http://api.anidb.net:9001/httpapi?client=$CLIENT_NAME&clientver=$CLIENT_VER&protover=1&request=anime&aid="
    readonly IMG_URL_BASE="https://cdn-us.anidb.net/images/main/"
    COUNTER=0 # This is used way later in the script, I just need it set to zero somewhere before the for loop uses it
}

function cache() {
    # This is to prevent a ban from anidb, because they're mean ):
    echo " [*  ] Checking Cache"
    mkdir -p "$CACHE/$SHOW_ID" # It's quicker to make the dir every time, so fuck you
    LAST_MODIFIED=$(stat -c %Y "$CACHE/$SHOW_ID/data.xml" 2>/dev/null) # Check cache time
    if [ $? -eq 1 ]; then LAST_MODIFIED=0; fi # If the file doesn't exist, set 0 to force update
    if [ "$(echo "$(date +%s)"-"$LAST_MODIFIED" | bc)" -lt "86400" ]
    then
        echo " [*  ] Cache is new enough, not updating"
    else
        echo " [ * ] Updating cache"
        curl -sH 'Accept-encoding: gzip' "$META_URL_BASE$SHOW_ID" | gunzip - > "$CACHE/$SHOW_ID/data.xml"
        wget -qO "$CACHE/$SHOW_ID/cover.jpg" $IMG_URL_BASE"$(xmlstarlet sel -t -v '//picture' "$CACHE"/"$SHOW_ID"/data.xml | head -1)"
        echo " [*  ] Cache updated"
    fi
}

function parse() {
    # This function is mostly done by ChatGPT, as I do not understand xmlstarlet at all
    echo " [*  ] Parsing xml"

    echo " [*  ] Getting episode count" # This also silently sets up padding
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

    # The example uses One Piece numbers, but this will work with any padding
    # The long xmlstarlet command grabs any episode name that is marked as type 1 (a real episode) with the episode number in front of it
    # padded out to 0001-1000, then sorts them so the episodes are in the correct order (some shows have them out of order, don't ask why)
    # Then we cut the episode numbers off to leave us with just the names in order, and then we change all back ticks to single quotes,
    # to match every sane fucking naming method. It's terrible, it shouldn't exist, ChatGPT literally wrote the ENTIRE xmlstarlet part because
    # I could not figure it out. :3
}

function build_array() {
    # I didn't wanna rewrite this code so shutup
    readarray -d '' episodes_array < <(find "$SHOW_PATH" -mindepth 1 -maxdepth 1 -type f -print0)
    readarray -t episodes_sorted < <(printf '%s\n' "${episodes_array[@]}" | sort)
}

function rename() {
    # This code will throw a lot of "cannot stat ''" warnings if you have less episodes than what has aired.
    echo " [*  ] Quickly building episode array" # I didn't know where else to put this code :3
    build_array

    echo " [*  ] Renaming episodes"
    for EPISODE in $(seq -w 0 "$EPISODE_COUNT")
    do
        EPISODE_NUM=$(( 10#$EPISODE+1 )) # Bash starts at 0, shows start at 1, I need them to match
        EPISODE_NUM_LEN=${#EPISODE_NUM} # This is to deal with padding below
        PADDING_REQ=$(($( echo ${#EPISODE_COUNT}-"$EPISODE_NUM_LEN" | bc))) # Subtract len of episodes by len of the current episode number
        PADDING=$(head -c "$PADDING_REQ" /dev/zero | tr '\0' '0') # Create the zeros for padding
        mv -v "${episodes_sorted[10#$EPISODE]}" "$SHOW_PATH"/"$SHOW_NAME"\ -\ S"$SEASON_NUMBER"E"$PADDING""$EPISODE_NUM"\ -\ "${EPISODE_NAMES[10#$EPISODE]}".mkv # Renname the episodes
    done
}

function metadata() {
    # This function is braindead but it works
    echo " [*  ] Embedding episode names"
    build_array # The files are different, we need to rebuild the arrays
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
                fi
                ;;
            n)
                numbers='^[0-9]+$'
                if ! [[ $OPTARG =~ $numbers ]]
                then
                    usage
                else
                    SHOW_ID="$OPTARG"
                fi
                ;;
            s)
                numbers='^[0-9]+$'
                if ! [[ $OPTARG =~ $numbers ]]
                then
                    usage
                else
                    SEASON_NUMBER="$OPTARG"
                fi
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
    if [ -z "$SHOW_PATH" ] || [ -z "$SHOW_ID" ]; then
        usage
    fi
    main
}

# SHOW_PATH=i
# SHOW_ID=n
# SEASON=s

prep "$@"
