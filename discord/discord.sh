#!/bin/bash

# This is a script that helps create a version of discord that works on wayland, has audio screensharing, and hopefully more in the future.

usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
Usage: $program_name [--option]
Options:
    --help           Print this message
    --install        Installs chromium, and creates a .desktop file to load it
    --uninstall      The opposite of install
    --about          Creates a text document in your home folder that tells you how this works

Info:
    This script will not be needed in the *very* distant future when discord actually decides to properly support linux
EOF
}

chromium_install(){
    clear
    echo "Detecting linux distro and installing required tools"
    linux=`cat /etc/os-release | grep ID= | cut -b 4- | head -1`
    case $linux in
	    arch|manjaro|endeavouros) sudo pacman -S chromium;;
        ubuntu|linuxmint|popos) sudo apt install -y chromium-browser;;
        *) echo "Your current setup is not supported by this script. If you want your system supported, please make a PR.";;
    esac
}

chromium_ext(){
    clear
    echo "Installing Chrome extensions"
    chromium --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --app=https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm
    chromium --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --app=https://chrome.google.com/webstore/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag
    chromium --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --app=https://openuserjs.org/scripts/samantas5855/Screenshare_with_Audio/
}

install_duncecord(){
    clear
    echo "Installing Duncecord"
    sudo mkdir -p /usr/share/duncecord
    sudo curl -o /usr/share/duncecord/icon.png "https://raw.githubusercontent.com/46620/Scripts/master/discord/extras/duncecord.png"
    sudo curl -o /usr/share/duncecord/duncecord.sh "https://raw.githubusercontent.com/46620/Scripts/master/discord/extras/duncecord.duncecord.sh"
    sudo chmod +x /usr/share/duncecord/duncecord.sh # Just in case it doesn't download as a runnable app
    sudo curl -o /usr/share/applications/duncecord.desktop "https://raw.githubusercontent.com/46620/Scripts/master/discord/extras/duncecord.desktop"
}

virtmic_setup(){
    clear
    echo "Setting up virtmic"
    sudo curl -o /usr/local/bin/virtmic "https://raw.githubusercontent.com/edisionnano/Screenshare-with-audio-on-Discord-with-Linux/main/virtmic"
    sudo chmod +x /usr/local/bin/virtmic # I do not actually remember if curl keeps chmod perms so fuck you
}

finalize(){
    clear
    echo "Duncecord and virtmic are now setup on the system, if there's any updates in the future, rerun this script and it'll update everything"
}

discord_install(){
    chromium_install
    chromium_ext
    install_duncecord
    virtmic_setup
    finalize
    exit 0
}

discord_uninstall(){
    echo "Uninstalling Duncecord"
    sudo rm -rvf /usr/share/duncecord
    sudo rm -rf /usr/local/bin/virtmic
    echo "All files are deleted, if you want to, you can uninstall Chromium"
}

script_about(){
    # This just generates a text file in the home folder
    cat << EOF > ~/duncecord.txt 
# What is this scripts?
This is a script that's main purpose is to allowe screensharing audio in discord which is somehow still missing from the linux versions.

# Why make this?
I wanted to automate doing this on multiple devices. I'm also currently on a roadtrip so I needed to do something to kill time

# How do I do the audio sharing?
First, open up the settings and make sure the mic **IS NOT SET TO DEFAULT**, please select a real microphone in order for this to work
Open a terminal, run 'virtmic' then open another terminal and run 'pw-cli ls Node' to find the name, copy that name and paste it into virtmic and hit Enter

# It's not working help me!!!!
First of all, I can't, this is a text file not live chat. If there's some issue, open up an audio patch bay (such as carla) and check how the audio is routed.
Your mic should be routed into only 'input_l' and 'input_r' or similar. The apps audio should be passed into the ones below (usually with random numbers and letters)
If neither of those help, you can reach me on discord @ 46620#4662 
EOF
}

main() {
    
    case "$1" in
        ''|-h|--help)
            usage
            exit 0
            ;;
        --install)
            discord_install
            ;;
        --uninstall)
            discord_uninstall
            ;;
        --about)
            script_about
            ;;
        *)
            echo "Command not found" >&2
            exit 1
    esac
}

main "$@"


# Credits
#
# 1. Discord for not caring for the Linux users and making us make workarounds (half /s)
# 2. Pipewire for being the best audio backend
# 3. The random USB-C car plug I've been using that's made it possible to charge my laptop in the car
# 4. edisionnano for the repo on getting audio screensharing working at all (https://github.com/edisionnano/Screenshare-with-audio-on-Discord-with-Linux)
# 5. "leroy - the dariacore to ytp pipeline" for being such a cluserfuck of a song to keep me focused on this task
# 6. Rhode Island for being a shit state and having zero service, making me wait a whole state to start working
# 7. https://www.maketecheasier.com/create-desktop-file-linux/ for teaching me how to make a desktop file
#
#
#
#
#
#
#