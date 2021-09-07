#!/bin/bash
########################################
# THIS WAS STOLEN FROM MY NX SCRIPT!!  #
########################################

###################
# Fucking kill me #
###################
mkdir -p {3ds,cias,luma/payloads} # saves me the slightest bit of time later
export script_start=`pwd`
########
# Luma #
########
echo "Downloading Luma"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/LumaTeam/Luma3DS/releases/latest | jq -r '.assets[0].browser_download_url' | wget -qi -
unzip -q Luma3DSv*.zip;rm Luma3DSv*.zip

#################
# Homebrew apps #
#################

echo "Downloading FBI" # might swap this out for the fork ngl
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/Steveice10/FBI/releases/latest | jq -r '.assets[].browser_download_url' | wget -qi -
rm -rf FBI.zip

echo "Downloading Anemone"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/astronautlevel2/Anemone3DS/releases/latest | jq -r '.assets[1].browser_download_url' | wget -qi -

echo "Downloading ftpd"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/mtheall/ftpd/releases/latest | jq -r '.assets[0].browser_download_url' | wget -qi -

echo "Downloading Checkpoint"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/FlagBrew/Checkpoint/releases/latest | jq -r '.assets[1].browser_download_url' | wget -qi -

echo "Downloading Universal Updater"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/Universal-Team/Universal-Updater/releases/latest | jq -r '.assets[1].browser_download_url' | wget -qi -

echo "Downloading Homebrew Launcher Wrapper" # is this just a blank cia to use as a forwarder?
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/mariohackandglitch/homebrew_launcher_dummy/releases/latest | jq -r '.assets[].browser_download_url' | wget -qi -

echo "Downloading GodMode9"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/d0k3/GodMode9/releases/latest | jq -r '.assets[].browser_download_url' | wget -qi -
mkdir tmp;mv GodMode9*.zip tmp;cd tmp/;unzip -q *.zip;mv GodMode9.firm ../luma/payloads;cd ..;rm -rf tmp

echo "Downloading DSP1"
wget -q "https://github.com/zoogie/DSP1/releases/download/v1.0/DSP1.cia" # Not updated since 2017 so not gonna do an API call

echo "Downloading crt-no-timeoffset" # Not updated since 2019 so not gonna do an API call
wget -q "https://github.com/ihaveamac/ctr-no-timeoffset/releases/download/v1.1/ctr-no-timeoffset.3dsx"

################
# Moving shit  #
################

echo "Putting homebrew files in correct locations"
mv *.cia cias
mv *.3dsx 3ds
mv 3ds/boot.3dsx $script_start

#################
# First Archive #
#################
echo "Making cleanSD zip archive"
7z a -tzip "out/latest-cleanSD.zip" * > /dev/null
cd out
md5sum "latest-cleanSD.zip" > "latest-cleanSD.zip.md5"
cd ..

##############
# browserhax #
##############
echo "Downloading browserhax files"
wget -qO "arm11code.bin" "https://github.com/TuxSH/universal-otherapp/releases/download/v1.3.0/otherapp.bin" # I do not think this is gonna get many updates, if it starts updating a lot I'll use the api
wget -qO "boot9strap.zip" "https://github.com/SciresM/boot9strap/releases/download/1.3/boot9strap-1.3.zip" # Has not been updated since 2017, should be no reason to call the api
wget -qO "SafeB9SInstaller.zip" "https://github.com/d0k3/SafeB9SInstaller/releases/download/v0.0.7/SafeB9SInstaller-20170605-122940.zip" # Same reason as above
unzip -q boot9strap.zip
rm boot9strap.zip
mkdir boot9strap
mv boot9strap.fir* boot9strap
mkdir tmp;mv SafeB9SInstaller.zip tmp;cd tmp;unzip -q SafeB9SInstaller.zip; mv SafeB9SInstaller.bin ..;cd ..;rm -rf tmp

######################
# browserhax archive #
######################
echo "Making browserhax archive"
7z a -tzip "out/latest-browserhax.zip" * -x\!out > /dev/null
cd out
md5sum "latest-browserhax.zip" > "latest-browserhax.zip.md5"
cd ..

###########
# Credits #
###########
# One liner to download latest release: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-2724872
# My friend Logan for being in voice with my while not doing his school work
# Will Stetson for making the music I am listening to while doing this https://www.youtube.com/watch?v=8daZtdrFmBY
# My friend Brandon's DS that had a broken start button making it so I had to use browserhax and add the second zip file
# My boyfriend for letting me use him as a pillow a few times a week to keep me alive
