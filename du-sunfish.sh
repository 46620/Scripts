#!/bin/bash


echo DU HAVE CLOSED THEIR DOORS! THIS WILL STILL WORK BUT PLEASE USE A DIFFERENT ROM
sleep 10
echo "Install build dependencies"
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev libncurses5 git openjdk-8-jdk python adb fastboot

echo "Installing latest version of repo"
sudo curl https://storage.googleapis.com/git-repo-downloads/repo > repo
sudo mv repo /usr/local/bin/repo
sudo chmod a+x /usr/local/bin/repo

# If you are reading this ily <3

echo "Creating work directories"
sleep 1
sudo mkdir -p /opt/android/DU
sudo chown $USER:$USER /opt/android/DU
cd /opt/android/DU

echo "Cloning DirtyUnicorns source"
sleep 5
repo init -u https://github.com/DirtyUnicorns/android_manifest.git -b r11x
repo sync --force-sync --prune --optimized-fetch --no-clone-bundle --force-remove-dirty

echo "Now time to build, go take a nap, it'll be done by then (THIS REQUIRES ~250GB OF STORAGE)"
sleep 5
cd /opt/android/DU
. build/envsetup.sh
lunch du_sunfish-userdebug
mka bacon
