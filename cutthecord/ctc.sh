#!/bin/bash

# Author: 46620
# Start time: 2021-07-25
# Stackoverflow posts that helped: 4277665, 630372
# Scripts that helped: dikiaap/dotfiles install.sh, 

# This script is kind of a "master brain" script I wrote in order to make working on ctc easier.

############################
# Quick gross dump of vars #
############################
CTCTOP=/opt/cutthecord
CTCPATCHESPATH=$CTCTOP/cutthecord/patches
CTCPATCHES=(`ls -Ibranding -Ibettertm -Iblobs -Icustomfont -Icustomring $CTCPATCHESPATH`)
CTCBASE=$CTCTOP/com.discord
CTCRES=$CTCTOP/ctc
CTCBLOBS=$CTCTOP/blobs

# Print usage message.
usage() {
    local program_name
    program_name=${0##*/}
    cat <<EOF
Usage: $program_name [-option]
Options:
    --help    Print this message
    --clone   Cleans and clones the CutTheCord repos
    --build   Builds CutTheCord from a given directory
    --install Builds CutTheCord and Installs it to a connected device
    --setup   Sets up a directory in /opt and installs the last version of apktool
    --update  Updates the script to the latest
EOF
}

cutthecord_clone() {
	clear
	echo Cloning repos, please wait.
	sleep 2
    cd $CTCTOP
    rm -rf *
    git clone https://booba.tech/femboy-apps/discord/cutthecord.git
    git clone --depth=1 https://booba.tech/femboy-apps/discord/discord.git
    cp -r discord/com.discord .
    git clone https://booba.tech/femboy-apps/discord/blobs.git
    git clone https://booba.tech/femboy-apps/discord/ctc.git
    echo "Clone complete, please update your patches or run the build command"
}

cutthecord_build() {
	clear
	echo Building CTC this will take a moment.
	sleep 2
	# credit 5
	if [ -d "$CTCTOP" ]
	then
		if [ "$(ls -A $CTCTOP)" ]
		then
	    	keystore_setup
	    	clear
	    	echo Patching discord now, please wait...
	    	sleep 1
	    	cd $CTCTOP/cutthecord
			ver=`cat patchport-state.json | jq -r .versioncode`
			cd $CTCTOP/cutthecord/patches/branding
			python3 addpatch.py $ver.patch $CTCNAME $CTCBRANCH
			cd $CTCTOP/com.discord
			# credit 6
			for cum in ${CTCPATCHES[@]}
			do 
				patch -p1 < $CTCPATCHESPATH/$cum/$ver.patch
			done
			patch -p1 < $CTCPATCHESPATH/branding/$ver-custom.patch
			python3 $CTCPATCHESPATH/blobs/emojireplace.py
			sleep 1
			clear
			echo "Patches applied, building apk"
			apktool b
			echo $KEYSTORE_ALIAS
			jarsigner -keystore $KEYSTORE_PATH -storepass $KEYSTORE_PASSWD $CTCBASE/dist/com.cutthecord.$CTCBRANCH-$ver.apk $KEYSTORE_ALIAS
		else
			echo "$CTCTOP is empty, please run --clone first"
			exit
		fi
	else
		echo "Directory does not exist, run --setup first"
	fi
	sleep 2
	clear
	echo "CutTheCord has been built. Please install it either by moving the apk to your phone or adb"
	echo "The script can also auto install the script if you do --install instead of --build"
}

cutthecord_install() {
	cutthecord_build
	read -p "Plug your device in and then press [Enter]"
	echo "Installing to device"
	adb install $CTCBASE/dist/com.cuttheccord.$CTCBRANCH-$ver.apk
}

cutthecord_setup() {
	clear
	echo "Setting up cuttheccord environment"
	sleep 1
	sudo mkdir -p $CTCTOP
	sudo wget -O "/usr/local/bin/apktool" https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
	sudo wget -O "/usr/local/bin/apktool.jar" https://ci.46620.moe/job/Auto%20Builds/job/apktool/lastSuccessfulBuild/artifact/brut.apktool/apktool-cli/build/libs/apktool-cli-all.jar
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

keystore_setup() {
	clear
	read -p "What would you like the app to be called? " CTCNAME
	read -p "What is the name of this CTC branch? " CTCBRANCH
	read -p "Where is your keystore file? " KEYSTORE_PATH
	read -p "What is the keystore alias? " KEYSTORE_ALIAS
	echo "What is your keystore password? "
	read -s KEYSTORE_PASSWD
	echo "Type your password again: "
	read -s KEYSTORE_PASSWD_VERIFY
	clear
	# stackoverflow 1
	if [[ $KEYSTORE_PASSWD == $KEYSTORE_PASSWD_VERIFY ]]
	then
		# credit 4
		while true; do
		clear
		echo "CutTheCord name: $CTCNAME"
		echo "CutTheCord branch: $CTCBRANCH"
		echo "Keystore path: $KEYSTORE_PATH"
		echo "Keystore alias: $KEYSTORE_ALIAS"
	        read -p "Is this information correct? " yn
	        case $yn in
	            [Yy]* ) break;;
	            [Nn]* ) exit;;
	            * ) echo "Please answer yes or no.";;
	        esac
	    done
	else
		echo "Passwords do not match, Press Enter to try again"
		read
		keystore_setup
	fi
}

main() {
    
    case "$1" in
        ''|-h|--help)
            usage
            exit 0
            ;;
        --clone)
            cutthecord_clone
            ;;
        --build)
            cutthecord_build
            ;;
        --install)
            cutthecord_install
            ;;
        --setup)
            cutthecord_setup
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
