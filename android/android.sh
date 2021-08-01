#!/bin/bash

# Author: 46620
# Start Date: 2021-07-30

#
# Vars I need to set here cause they're needed everywhere
#



# Print usage message.
usage() {
	local program_name
	program_name=${0##*/}
	cat <<EOF
Usage: $program_name [-option]
Options:
    --help    Prints this message
    --install Installs build deps for your OS
EOF
}

find_os() {
	clear
	echo Installing build tools for your Linux distro
	OS="$(uname -s)"
	case "${OS}" in
	    Linux*)     find_linux;;
	    *)          unsupported_os;;
	esac

}


find_linux(){
	linux=`cat /etc/os-release | grep ID_LIKE= | cut -b 9-`
	case $linux in
		[arch]) android_deps_arch;;
        [debain]) android_deps_deb;;
        [fedora]) android_deps_fedora;;
}

android_deps_arch() {
	echo "Installing yay to make installing the packages easier"
	git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    yay -S lineageos-devel
    sudo pacman -S python2 -y # Sadly py2 is still used to make android, in the future this will be removed
    install_repo
    echo "Build tools installed"
    exit
}

android_deps_deb() {
	sudo apt-get install -y git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip squashfs-tools python-mako libssl-dev ninja-build lunzip syslinux syslinux-utils gettext genisoimage gettext bc xorriso xmlstarlet
	install_repo
    echo "Build tools installed"
    exit
}

android_deps_fedora() {
	echo Not set up yet, please come back later
}


install_repo() {
	sudo curl https://storage.googleapis.com/git-repo-downloads/repo > repo
	sudo mv repo /usr/local/bin/repo
	sudo chmod a+wx /usr/local/bin/repo
}







unsupported_os() {
	echo "$OS is not supported, please use linux"
	exit
}

main() {

	case "$1" in
		''|-h|--help)
            usage
            exit 0
            ;;
        --install)
            find_os
    esac
}

main "$@"