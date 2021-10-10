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
    --download       Downloads the tlmc collection (Currently does not work)
    --tta-flac       Convert all tta files to flac and exit (Currently being worked on)
    --album-art      Adds album art to split flacs (not implemented)
    --flac-cue       Splits flac files based on cue sheet and renames split files (not implemented)
    --setup          Installs all the tools that will be required (only supports ubuntu and arch currently)
    --run            Do literally everything (not implemented)
    --update         Updates the script to the latest

Info: This script should be ran with a directory looking like this in order to work properly. (this does not apply to --download)
          .
          ├── script.sh
          └── Touhou lossless music collection
      Please ensure it looks like that in order for commands to work.
EOF
}

tlmc_download() {
    echo "This option is not implemented. This will be added in a later commit."
}

tlmc_convert() {
    echo "Converting all .tta files to .flac."
    find . -iname "*.tta" -exec ffmpeg -i \{\} \{\}.flac \;
    echo "Deleting the original .tta files."
    find . -iname "*.tta" -exec rm -rvf \{\} \;
}

tlmc_art() {
    echo "This option is not implemented. This will be added in a later commit."
}

tlmc_split(){
    echo "Splitting files, this can take a fuckton of time." # I have not tested this across the entire tlmc folder as I am not ready for that level commitment yet
    files=()
    while IFS=  read -r -d $'\0'; do
        files+=("$REPLY")
    done < <(find . -iname "*.tta.flac" -print0 | cut -b 3- | sed 's/.tta.flac//g') # the 9 should be a 4 but because of my dumbass way of converting files kept the old file extension in it

    for name in "${files[@]}"
    do
        shnsplit -f "$name".cue -o flac -t "%n. %t" "$name".tta.flac
        mv *.flac "$(dirname "$name")"
    done
    echo "Deleting all the unsplit files"
    find . -iname "*.tta.flac" -exec rm -f \{\} \;
}

tlmc_setup() {
    echo "Installing the required programs"
    find_linux(){
	    linux=`cat /etc/os-release | grep ID_LIKE= | cut -b 9-`
	    case $linux in
		    [arch]) sudo pacman -S shntool cuetools;;
            [debain]) sudo apt install -y shntool cuetools;;
        esac
    }
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
        --run)
            tlmc_all
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
# 2. TLMC for their amazing archive of Touhou music
# 3. rwx for maintaining tlmc
# 4. SlvrEagle23 for being the best dev and seeing my tweet even though I didn't mean for him to (https://twitter.com/SlvrEagle23/status/1442926858924822528)