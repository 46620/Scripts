#!/bin/bash
# Author: PhazonicRidley https://gitlab.com/PhazonicRidley
# Date: 05/21/2018
# init
function pause(){
   read -r -p "$*"
}


echo "install the rest of your system"

su -c "pacman-key --init; pacman -Syu -y; pacman -S base base-devel -y"

#Set up passwords for root and alarm users

echo "Change root and alarm's password"
su -c "passwd"
passwd alarm

echo "Now please uncomment %Wheel ALL=(ALL)ALL [Press Enter]"
pause
su -c "EDITOR=nano visudo"

#set locale before running this script
#do ls /usr/share/zoneinfo to find your location file

#rm /etc/locale

#ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localetime

echo "uncomment your locale to gen [Press Enter]"
pause
sudo nano /etc/locale.gen
sudo locale-gen 
echo "If you plan to use tmux, you will have to do some extra steps, but we will worry about that later"


#add hosts

echo "Do you want to change your hostname?[Y,n]"
read -r input

if [[ "$input" = "y" || "$input" = "Y" ]]; then
        sudo nano /etc/hostname
        echo "ok, now we have to update /etc/hosts. I will add the template, replace <yourhostname> with your hostname"
        pause
        sudo echo "127.0.0.1 localhost.localdomain localhost <yourhostname>" >> /etc/hostname
        sudo nano /etc/hosts
elif [[ "$input" = "n" || "$input" = "N" ]]; then
        sudo echo "alright, I will keep your hostname $(alarmpi) and update /etc/hosts for you"
        sudo echo 127.0.0.1 localhost.localdomain localhost alarmpi >> /etc/hosts
fi


echo "Ok, now we are going to make the pi user"
sudo useradd -m -G wheel -s /bin/bash pi
sudo passwd pi

echo "Finishing up and installing the aur..."
sudo pacman -S git -y

echo "exiting root" 

git clone https://aur.archlinux.org/pacaur.git
cd pacaur
makepkg -csi

echo "aur installed! [Press Enter]"
pause

echo "Ok my work is done, however, there may be a few more things you would like to install if you want, I can auto install them please use the menu below. [Press Enter]"
pause
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
#if i think of any more shit to add to the list i will if you think of anything, dm PhazonicRidley#1432 on discord
echo "ok all done logging out [Press Enter]"
pause

exit

