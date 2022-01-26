#!/bin/bash

# Oh boy here we go again

# This script won't do anything cool except install all the basic tools. I just can't fucking stand having to set this up every single time I start a new VM.
# Oh yeah this is debian based shit only

echo "Installing build tools"
sudo apt install python bc bison build-essential git imagemagick lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libxml2 lzop pngcrush rsync schedtool git-core gnupg flex gperf zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip squashfs-tools python-mako libssl-dev ninja-build lunzip syslinux syslinux-utils gettext genisoimage xorriso xmlstarlet jq

mkdir -p ~/.local/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.local/bin/repo
chmod a+x ~/.local/bin/repo
export PATH="$HOME/.local/bin:$PATH" >> ~/.bashrc
git config --global user.email "android@builder.co"
git config --global user.email "builder vm"
echo "All set, please run `source ~/.bashrc` to add repo to your path"