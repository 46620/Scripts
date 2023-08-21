#!/bin/bash
# Oh god I never thought I'd have do this shit properly

# Print usage message.
usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
Usage: $program_name [--option]
Options:
    --help           Print this message
    --download       Downloads the tlmc collection (Currently v19)
    --tta-flac       Convert all tta files to flac and exit
    --album-art      Adds album art to split flacs (not implemented)
    --flac-cue       Splits flac files based on cue sheet and renames split files (not fully tested)
    --setup          Installs all the tools that will be required
    --update         Updates the script to the latest

Info: This script should be ran with a directory looking like this in order to work properly. (this does not apply to --download)
          .
          ├── script.sh
          └── Touhou lossless music collection
      Please ensure it looks like that in order for commands to work.
EOF
}

tlmc_download() {
    if ! [ -x "$(command -v aria2c)" ]
    then
        echo "Aria2c not found. Please run --setup and then rerun this"
    else
        echo "Downloading torrent file"
        wget -q "https://cdn.discordapp.com/attachments/337095801820020746/892792704298262528/Touhou_lossless_music_collection_v.19.torrent"
        echo "Downloading the collection using Aria2c (This will take at minimum 5 hours)"
        aria2c --seed-time=0 --enable-dht=true --enable-peer-exchange=true Touhou_lossless_music_collection_v.19.torrent
    fi
}

tlmc_convert() {
    # TODO: MAKE FASTER
    echo "Converting all .tta files to .flac."
    find . -iname "*.tta" -exec ffmpeg -i \{\} \{\}.flac \;
    echo "Deleting the original .tta files."
    find . -iname "*.tta" -exec rm -rvf \{\} \;
}

tlmc_art() {
    echo "This option is not implemented. This will be added in a later commit."
    exit 1
    if ! [ -x "$(command -v aria2c)" ]
    then
        echo "Aria2c not found. Please run --setup and then rerun this"
    else
        echo "Downloading scans to pull album art from"
        wget -q "https://cdn.discordapp.com/attachments/337095801820020746/897738282601967626/Touhou_album_image_collection_v.19.torrent"
        aria2c --seed-time=0 --enable-dht=true --enable-peer-exchange=true Touhou_album_image_collection_v.19.torrent
        # TODO: make sure shit is in the right spot
        #       make sure all images can be split the same
        #       write the split function
        #       debate to either embed the image into all tracks or leave a "cover.jpg" for all music players to use
    fi
}

tlmc_split(){
    echo "Splitting files, this can take around 34 hours." # I ran this across the entire folder and 105 things errored and didn't give anything due to illegal characters like slashes. I do not currently have a way other than manually fixing them yourself.
    files=()
    while IFS=  read -r -d $'\0'; do
        files+=("$REPLY")
    done < <(find . -iname "*.tta.flac" -print0 | cut -b 3- | sed 's/.tta.flac//g')

    for name in "${files[@]}"
    do
        shnsplit -f "$name".cue -o flac -t "%n. %t" "$name".tta.flac
        mv *.flac "$(dirname "$name")"
        echo "Deleting the original tta and cue sheet"
        rm $name.cue
        rm $name.tta.flac
    done
    echo "If you want to see a possible known list of missing files, click the link below. In a future commit it will be changed to a torrent link with the proper files in it."
    echo "https://cdn.discordapp.com/attachments/892270927314841640/897511251809275964/missing.txt"
}

tlmc_setup() {
    echo "Installing the required programs and adding the script to PATH"
    # TODO: MAKE CLEANER
    linux=`cat /etc/os-release | sed -n 's/^ID=//p'`
    case $linux in
	    arch|manjaro|endeavouros) sudo pacman -S cuetools flac aria2
        git clone https://aur.archlinux.org/shntool.git && cd shntool && makepkg -si;;
        ubuntu|linuxmint) sudo apt install -y shntool cuetools flac aria2;;
        *) echo "Your current setup is not supported by this script. If you want your system supported, please make a PR.";;
    esac
}

tlmc_update() {
    local program_name
    program_name=${0##*/}
	clear
	echo "Updating the script please wait..."
	sleep 2
	SCRIPT_PATH="`dirname \"$0\"`"
	wget -O "$SCRIPT_PATH/$program_name" "https://raw.githubusercontent.com/46620/Scripts/master/tlmc.sh"
	exit
}

main() {
    
    case "$1" in
        ''|-h|--help)
            usage
            exit 0
            ;;
        --download)
            tlmc_download
            ;;
        --tta-flac)
            tlmc_convert
            ;;
        --album-art)
            tlmc_art
            ;;
        --flac-cue)
            tlmc_split
            ;;
        --setup)
            tlmc_setup
            ;;
        --update)
            tlmc_update
            ;;
        *)
            echo "Command not found" >&2
            exit 1
    esac
}

main "$@"


# Credits
#
# 1. Azuracast for being a really good self hosted radio software
# 2. TLMC for their amazing archive of Touhou doujin music
# 3. rwx for maintaining tlmc
# 4. SlvrEagle23 for being the best dev and seeing my tweet even though I didn't mean for him to (https://twitter.com/SlvrEagle23/status/1442926858924822528)