#!/bin/bash

ps4_payload_sender() {
    clear
    ps4_config_file_check
    clear
    read -p "Drag and drop the payload here: " payload
    eval payload=$payload
    nc -c -v -v $PS4_IP 9020 < "$payload" # So fun thing I learned while testing this comment, sending goldhen 5-6 times to the same system will crash it. It also works on windows but not Linux.
}

ps4_ftp_dump(){
    clear
    ps4_config_file_check
    clear
    echo "Press Enter to dump the game (Make sure that the game is open first)"
    wget -O /tmp/ftpdump "https://raw.githubusercontent.com/hippie68/ftpdump/main/ftpdump"
    chmod +x /tmp/ftpdump
    /tmp/ftpdump $PS4_IP:2121 $HOME/Documents
    echo "Package now dumped, have a great day (in the future this will allow you to do multiple dumps)"
}

ps4_remote_install() {
    clear
    ps4_config_file_check
    clear
    read -p "Drag and drop the pkg here: " pkg
    eval pkg=$pkg
    wget -O /tmp/sender "https://dl.46620.moe/script-deps/ps4/sender"
    chmod +x /tmp/sender
    /tmp/sender "$pkg" "$PS4_IP"
    echo "Package now installed, have a great day (in the future this will allow you to do multiple installs)"
}

ps4_config_file() {
    clear
    echo "Config does not exist, creating..."
    touch "$HOME/.config/ps4.conf"
    read -p "What is your PlayStation 4's IP address? " PS4_IP
    echo "PS4_IP=$PS4_IP" > "$HOME/.config/ps4.conf"
}

ps4_config_file_check() {
    test -f "$HOME/.config/ps4.conf" && source "$HOME/.config/ps4.conf" || ps4_config_file
}

script_about() {
    clear
    echo "PS4-AIO script by 46620
    This script is a WIP AIO script for a modded PS4
    This was created due to most of the shit for the PS4 being windows only and barely working or not at all with Wine.
    Hopefully in the future the entire script will be complete and functional.
    The ftp command is based off of hippie68's ftpdump script, as it literally just calls their script and runs it."
}

script_update() {
    local program_name
    program_name=${0##*/}
	clear
	echo "Updating the script please wait..."
	sleep 2
	#stackoverflow 2
	SCRIPT_PATH="`dirname \"$0\"`"
	wget -O "$SCRIPT_PATH/$program_name" "https://raw.githubusercontent.com/46620/Scripts/master/homebrew/utilities/ps4.sh"
	exit
}

main() {
    PS3='What would you like to do: '
    options=("Send payload (WIP)" "Dump game over FTP" "Build fakepkg (WIP)" "Remote Install" "About" "Update" "Quit")
    clear
    select com in "${options[@]}"; do
        case $com in
            "Send payload (WIP)")
                echo "Currently the script crashes the console."
                exit 1
                ps4_payload_sender
                break
                ;;
            "Dump game over FTP")
                echo "This is currently being worked on, come back in another update"
    	        exit 1
                ps4_ftp_dump
                break
                ;;
            "Build fakepkg (WIP)")
                echo "This is currently being worked on, come back in another update"
    	        exit 1
                ;;
            "Remote Install")
                ps4_remote_install
    	        break
                ;;
            "About")
                script_about
                break
                ;;
            "Update")
                script_update
                break
                ;;
    	    "Quit")
    	        echo "Okay, Have a fucked day :)"
    	        exit 0
    	        ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

main "$@"