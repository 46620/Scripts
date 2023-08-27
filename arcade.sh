#!/bin/bash

# This script will be used until I find a hardware solution

# Script to select what to start in a custom built arcade cabinet
# All this shit is basically stolen from https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script but done in a slightly cleaner way

# This script will ALWAYS assume that everything required is installed and won't prompt the user about it, but I will list what is needed below
# dialog
# Kwin
# emulationstsation-de
# clonehero

# TODO:
# Fix update function
# Make code a bit cleaner and easier to read
# Fix any bugs found

vars() {
    # Command vars
    WM_LOADER="kwin_wayland --exit-with-session"
    # Dialog's variables
    HEIGHT=15
    WIDTH=40
    CHOICE_HEIGHT=6
    BACKTITLE="46620 menu v0.0.2a"
    TITLE="ARCADE BOOT MENU"
    MENU="What would you like to play?"
    OPTIONS=(1 "ES-DE"
         2 "Clone Hero"
         3 "Operator Settings"
         4 "Shutdown")
}

function operator() {
    OPTIONS=(1 "CLI"
         2 "Update emulator configs (WIP)"
         3 "Update script")

    OPERATE=$(DIALOGRC=arcade.dialog dialog --clear \
           --backtitle "$BACKTITLE" \
           --title "$TITLE" \
           --menu "$MENU" \
           $HEIGHT $WIDTH $CHOICE_HEIGHT \
           "${OPTIONS[@]}" \
           2>&1 >/dev/tty)
    
    case $OPERATE in
        1) clear && exit 0;;
        2) update_emu_configs;;
        3) update;;
    esac
}

function menu() {
    GAME=$(DIALOGRC=arcade.dialog dialog --clear \
           --backtitle "$BACKTITLE" \
           --title "$TITLE" \
           --menu "$MENU" \
           $HEIGHT $WIDTH $CHOICE_HEIGHT \
           "${OPTIONS[@]}" \
           2>&1 >/dev/tty)
}

function game_select() {
    case $GAME in
        1) $WM_LOADER emulationstation;;
        2) $WM_LOADER clonehero;;
        3) operator;;
        4) shutdown 0;;
    esac
}

function update_emu_configs() {
    clear
    echo "This feature is not implemented yet. It should be ready in a few updates."
    exit 1
}

function update() {
    local program_name
    program_name=${0##*/}
	clear
	echo "Updating the script please wait..."
	sleep 2
	SCRIPT_PATH="`dirname \"$0\"`"
	wget -O "$SCRIPT_PATH/$program_name" "https://raw.githubusercontent.com/46620/Scripts/master/arcade.sh"
	exit
}

function menu_config() {
    # This function is just so I don't need to supply this file myself
    # And yes, this runs every single run, it's in case I update it in the future.
    dialog --create-rc arcade.dialog
    sed -i 's@screen_color = (CYAN,BLUE,ON)@screen_color = (CYAN,BLACK,ON)@g' arcade.dialog
    sed -i 's@border_color = (WHITE,WHITE,ON)@border_color = (WHITE,BLACK,ON)@g' arcade.dialog
    sed -i 's@dialog_color = (BLACK,WHITE,OFF)@dialog_color = (WHITE,BLACK,OFF)@g' arcade.dialog
    sed -i 's@title_color = (BLUE,WHITE,ON)@title_color = (BLUE,BLACK,ON)@g' arcade.dialog
    sed -i 's@button_key_inactive_color = (RED,WHITE,OFF)@button_key_inactive_color = (RED,BLACK,OFF)@g' arcade.dialog
    sed -i 's@button_label_inactive_color = (BLACK,WHITE,ON)@button_label_inactive_color = (WHITE,BLACK,ON)@g' arcade.dialog
}

main() {
    menu_config
    vars
    while true; do
        menu
        game_select
    done
}

main