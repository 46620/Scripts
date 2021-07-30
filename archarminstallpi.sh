#!/bin/bash
# Author: PhazonicRidley https://gitlab.com/PhazonicRidley
# Date: 05/21/2018
# Modded by 46620 https://46620.moe
# Date 07/30/2021
# init

echo "install the rest of your system"

su -c "pacman-key --init; pacman -Syu -y; pacman -S base base-devel linux linux-headers -y"

#Set up passwords for root and alarm users

echo "Change root's and alarm's password"
su -c "passwd"
passwd alarm

read -p "Now please uncomment %Wheel ALL=(ALL)ALL [Press Enter] "
su -c "EDITOR=nano visudo"

#set locale before running this script
#do "ls /usr/share/zoneinfo" to find your location file

#rm /etc/locale

#ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localetime

read -p "Uncomment your locale [Press Enter] "

sudo nano /etc/locale.gen
sudo locale-gen

#add hosts

read -p "What would you live your host name to be? " HOSTNAME
sudo echo $HOSTNAME > /etc/hostname
sudo echo "127.0.0.1 localhost.localdomain localhost $HOSTNAME" >> /etc/hostname

#user account

echo "Now we will make your user account"
read -p "What would you live the user account to be called? " $PI_USER
sudo useradd -m -G wheel -s /bin/bash $PI_USER
sudo passwd $PI_USER

echo "Finishing up and installing the AUR..."
sudo pacman -S git -y

echo "exiting root" 

git clone https://aur.archlinux.org/pacaur.git
cd pacaur
makepkg -csi

read -p "AUR installed! [Press Enter]"

read -p "Ok my work is done, however, there may be a few more things you would like to install if you want, I can auto install them please use the menu below. [Press Enter]"

PS3='Please enter your choice to install: '
options=("python" "java-jdk" "neofetch" "tmux" "weechat" "wget" "metasploit" "7zip" "xdg-user-dirs" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "python")
            sudo pacman -S python -y
            ;;
        "java-jdk")
            echo "this will take a bit"
            pacaur -S jdk-arm -y
            ;;
        "neofetch")
            pacaur -S neofetch -y
            ;;
        "tmux")
            echo "you will need to fix the locale issue"
           sudo pacman -S tmux -y
            ;;
        "weechat")
            sudo pacman -S weechat -y
            ;;
        "wget")
            sudo pacman -S wget -y
            ;;
        "metasploit")
            sudo pacman -S metasploit metasploit-git -y
            ;;
        "7zip")
            sudo pacman -S p7zip -y
            ;;
        "xdg-user-dirs")
            sudo pacman -S xdg-user-dirs
            xdg-user-dirs-update
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
#if i think of any more shit to add to the list i will if you think of anything, dm PhazonicRidley#1432 or 46620#4662 on discord
read -p "Ok all done logging out [Press Enter] "


exit

