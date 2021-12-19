#!/bin/bash

# Author: 46620
# Start time: 2021-07-25
# Stackoverflow posts that helped: 4277665, 630372
# Scripts that helped: dikiaap/dotfiles install.sh, 

# This script is kind of a "master brain" script I wrote in order to make working on ctc easier.

# Print usage message.
usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
Usage: $program_name [--option]
Options:
    --help    Print this message
    --clone   Cleans and clones the CutTheCord repos
    --install Installs this script to your local bin directory for easy running
    --setup   Sets up a directory in /opt and installs some basic jar files
    --update  Updates the script to the latest

Info: This script is no longer used for building cutthecord, it's simply for updating patches.
      If you want to see the build script, please check out the jenkins script.
      This message will be removed next commit.
EOF
}

cutthecord_clone() {
	env_vars
	clear
	echo "Cloning repos, please wait."
	sleep 2
	if [ -d "$CTCTOP" ]
	then
        cd $CTCTOP
        rm -rf *
	    echo "Cloning patches"
        git clone --quiet https://booba.tech/CutTheCord/cutthecord.git
	    echo "Cloning discord"
        git clone --quiet --depth=1 https://booba.tech/CutTheCord/discord.git
        cp -r discord/com.discord .
	    rm -rf discord
	    echo "Grabbing tools"
	    mkdir tools
	    curl -sL https://api.github.com/repos/Aliucord/dex2jar/releases/latest | jq -r '.assets[].browser_download_url' | wget -O "$CTCTOOLS/dex2jar.jar" -i -
	else
	    echo "Please run the setup command before running this."
	fi
}

script_install() {
    if [[ -d $HOME/.local/bin ]]
    then
        echo "Installing/Updating ctc"
	    wget -O "$HOME/.local/bin/ctc" https://raw.githubusercontent.com/46620/Scripts/master/cutthecord/ctc.sh
	    chmod +x "$HOME/.local/bin/ctc"
        echo "Script installed, please make sure that $HOME/.local/bin is in your PATH before using this."
    else
        mkdir $HOME/.local/bin
        script_install
    fi
}

cutthecord_setup() {
    clear
    echo "Setting up cuttheccord environment"
    env_vars
    sleep 1
    sudo mkdir -p $CTCTOP
    sudo chown $USER:$USER $CTCTOP
	curl -sL https://booba.tech/CutTheCord/warppers/raw/branch/master/setup.sh | bash
}

script_update() {
    local program_name
    program_name=${0##*/}
	clear
	echo "Updating the script please wait..."
	sleep 2
	#stackoverflow 2
	SCRIPT_PATH="`dirname \"$0\"`"
	wget -O "$SCRIPT_PATH/$program_name" "https://raw.githubusercontent.com/46620/Scripts/master/cutthecord/ctc.sh"
	exit
}

env_vars(){
	CTCTOP=/opt/cutthecord
    CTCTOOLS=$CTCTOP/tools
}

main() {
    
    case "$1" in
        ''|-h|--help)
            usage
            exit 0
            ;;
        --setup)
            cutthecord_setup
            ;;
        --clone)
            cutthecord_clone
            ;;
        --install)
            script_install
            ;;
        --update)
            script_update
            ;;
        *)
            echo "Command not found" >&2
            exit 1
    esac
}

main "$@"


# Credits
#
# 1. Distok for the original CTC project: https://gitdab.com/distok
# 2. PhazonicRidley for being around to answer my dumb fuck questions over discord, without her dealing with my shit these scripts wouldn't exist: https://gitlab.com/PhazonicRidley
# 3. Sockdreams for making amazing programmer socks: https://www.sockdreams.com/
# 4. shellhacks: https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/
# 5. cyberciti: https://www.cyberciti.biz/faq/linux-unix-shell-check-if-directory-empty/
# 6. cyberciti: https://www.cyberciti.biz/faq/bash-loop-over-file/
# 99. My boyfriend for always being there for me whenever I need to destress
