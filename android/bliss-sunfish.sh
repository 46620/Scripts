#!/bin/bash

# This code is barely tested and will most likely break, there will be updates to it over time but for now this will work

echo "Install build dependencies"
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev libncurses5 git openjdk-8-jdk python adb fastboot

echo "Installing latest version of repo"
sudo curl https://storage.googleapis.com/git-repo-downloads/repo > repo
sudo mv repo /usr/local/bin/repo
sudo chmod a+wx /usr/local/bin/repo # making writeable cause repo updates a lot now

# If you are reading this ily <3

echo "Creating work directories"
sleep 1
sudo mkdir -p /opt/android/Bliss/r
sudo chown $USER:$USER /opt/android/Bliss/r
cd /opt/android/Bliss/r

echo "Cloning BlissRoms source"
sleep 1
repo init -u https://github.com/BlissRoms/platform_manifest.git -b r
repo sync -c --force-sync --no-tags --no-clone-bundle -j$(nproc --all) --optimized-fetch --prune
. build/envsetup.sh

# Hopefully should build
echo "Setting up CCACHE to save like... 4 hours"
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 100G
blissify -g sunfish
