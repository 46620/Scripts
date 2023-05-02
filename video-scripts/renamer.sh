#!/bin/bash

echo " [ * ] THIS SCRIPT HAS ONLY EVER BEEN TESTED ON ONE PIECE AND NOTHING ELSE! I DO NOT TRUST THIS TO WORK ON ANYTHING ELSE"

# This is the worst script I have ever made, unironically nothing can compare to this.
# And no, I will not clean this up or make it look better, ask me later.

# SET THESE VARIABLES WITH YOUR OWN USER AGENT AND SOCKS5 PROXY!
readonly USER_AGENT= # open a browser console and type navigator.useragent
readonly SOCKS5= # ip:port

if [[ -z $USER_AGENT ]]
then
    echo " [ * ] PLEASE EDIT THE SCRIPT TO SUPPLY A USER AGENT AND A SOCKS5 PROXY"
    exit 1
fi

if [[ -z $SOCKS5 ]]
then
    echo " [ * ] PLEASE EDIT THE SCRIPT TO SUPPLY A USER AGENT AND A SOCKS5 PROXY"
    exit 1
fi

# Checks to make sure that variables are correct
numbers='^[0-9]+$'

if ! [[ -d $1 ]] ; then
    echo "Show path is not a folder"
    exit 1
fi

if ! [[ $2 =~ $numbers ]] ; then
    echo "Show ID is not a number"
    exit 1
fi

# This is to just make the variables look cleaner in the actual commands
SHOW_PATH="$1" # For the LOVE OF FUCK clean your folder names
ANIME_ID=$2 # This can technically be automated by using $SHOW_PATH, but since I don't wanna dig out my anidb database parser, I am not doing that
EPISODE_COUNT=$((`ls "$SHOW_PATH" | wc -l`-1))
EPISODE_COUNT_FIXED=`echo $((10#$EPISODE_COUNT+1))`
if ! [[ -z $4 ]] ; then
    SEASON_NUMBER=$4
else
    SEASON_NUMBER=01
fi

# Grab the show information
echo " [ * ] Cleaning up any old script files"
rm -rf /tmp/46620/tmp_show
mkdir -p /tmp/46620/tmp_show
echo " [ * ] Downloading metadata"
curl -o /tmp/46620/tmp_show/show_page --user-agent -k -x "$USER_AGENT" -k -x socks5h://$SOCKS5 https://anidb.net/anime/$ANIME_ID
echo " [ * ] Ripping episode names, please wait a moment"
SHOW_NAME=`cat /tmp/46620/tmp_show/show_page | grep 'class="anime"' | tail -n1 | cut -b 28- | rev | cut -b 6- | rev`
cat /tmp/46620/tmp_show/show_page | grep "title name episode" -A 2 | sed 's/^.*\(itemprop="name".*\).*$/\1/' | cut -b 17- | sed '1~2d' | sed '/^$/d' | head -n 1059 > /tmp/46620/tmp_show/ep_name
sed -i sed "s@\`@'@g" /tmp/46620/tmp_show/ep_name
readarray -t ep_name < /tmp/46620/tmp_show/ep_name
cd "$SHOW_PATH"

# Until I figure out 2 arrays at once, first pass sets episode numbers, second will do names
echo " [ * ] Setting episode numbers"
readarray -d '' files_array < <(find . -name "*.mkv");
IFS=$'\n' files_sorted=($(sort <<<"${files_array[*]}"))
unset IFS

for episode in `seq -w 0 $EPISODE_COUNT`
do
    episode2=`echo $((10#$episode+1))`
    episode3=`expr length $episode2`
    episode4=`echo $(($(expr length $EPISODE_COUNT_FIXED)-$episode3))`
    episode5=`head -c $episode4 /dev/zero | tr '\0' '0'`
    mv -v "${files_sorted[10#$episode]}" "$SHOW_NAME - S`echo $SEASON_NUMBER`E$episode5$((10#$episode+1)).mkv"
done

echo " [ * ] Setting episode names"

readarray -d '' files_array < <(find . -name "*.mkv"| sed 's@.mkv@@g');
IFS=$'\n' files_sorted=($(sort <<<"${files_array[*]}"))
unset IFS

for episode in `seq -w 0 $EPISODE_COUNT`
do
    mv -v "${files_sorted[10#$episode]}.mkv" "${files_sorted[10#$episode]} - ${ep_name[10#$episode]}.mkv"
done

# Deps

# curl
