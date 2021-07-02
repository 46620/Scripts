#!/bin/bash

echo "Install build dependencies"
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev libncurses5 git openjdk-8-jdk python adb fastboot

echo "Installing latest version of repo"
sudo curl https://storage.googleapis.com/git-repo-downloads/repo > repo
sudo mv repo /usr/local/bin/repo
sudo chmod a+wx /usr/local/bin/repo # making writeable cause repo updates a lot now

echo "Creating work directory"
sleep 1
sudo mkdir -p /opt/android/Bliss
sudo chown -R $USER:$USER /opt/android
cd /opt/android/Bliss

echo "Cloning BlissRoms source"
repo init -u https://github.com/BlissRoms/platform_manifest.git -b q
repo sync --current-branch --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune

echo "Deleting random shit that you don't need I think"
sleep 1
rm -rf device/google/{bonito,bonito-kernel,sargo,bonito-sepolicy}
rm -rf kernel/google/bonito
rm -rf vendor/{google,images,gapps}

echo "Cloning some device shit"
git clone https://github.com/BlissRoms-Devices/android_device_google_bonito device/google/bonito
git clone https://github.com/BlissRoms-Devices/android_kernel_google_b4s4 kernel/google/b4s4
git clone https://github.com/BlissRoms-Devices/proprietary_vendor_google vendor/google
git clone https://gitlab.com/stebomurkn420/gapps.git -b bliss vendor/gapps

echo "Deleting files that caused issues when I did my first build"
rm -rf /opt/android/Bliss/vendor/bliss/packages/overlays/PixelSetupWizardOverlay
rm -rf /opt/android/Bliss/vendor/google-customization/interfaces/wifi_ext
sleep 2

echo "Now time to build, go take a nap, it'll be done by then (THIS REQUIRES ~250GB OF STORAGE)"
sleep 5
cd /opt/android/Bliss
. build/envsetup.sh
lunch bliss_sargo-userdebug
mka blissify
