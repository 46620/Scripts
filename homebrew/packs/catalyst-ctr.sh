#!/bin/bash
########################################
# THIS WAS STOLEN FROM MY NX SCRIPT!!  #
########################################

###################
# Fucking kill me #
###################
export script_start=`pwd`

########
# Luma #
########
echo "Downloading Luma"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/LumaTeam/Luma3DS/releases/latest | jq -r '.assets[0].browser_download_url' | wget -qi -

#################
# Homebrew apps #
#################
echo "Downloading FBI" # might swap this out for the fork ngl
curl -sLq https://api.github.com/repos/Steveice10/FBI/releases/latest | jq -r '.assets[].browser_download_url' | wget -qi -
rm -rf FBI.zip

echo "Downloading Anemone"
curl -sLq https://api.github.com/repos/astronautlevel2/Anemone3DS/releases/latest | jq -r '.assets[1].browser_download_url' | wget -qi -

echo "Downloading Universal Updater"
curl -sLq https://api.github.com/repos/Universal-Team/Universal-Updater/releases/latest | jq -r '.assets[1].browser_download_url' | wget -qi -

echo "Downloading GodMode9"
curl -sLq https://api.github.com/repos/d0k3/GodMode9/releases/latest | jq -r '.assets[].browser_download_url' | wget -qi -

echo "Downloading DSP1"
wget -q "https://github.com/zoogie/DSP1/releases/download/v1.0/DSP1.cia" # Not updated since 2017 so not gonna do an API call

echo "Downloading ctr-no-timeoffset" # Not updated since 2019 so not gonna do an API call
wget -q "https://github.com/ihaveamac/ctr-no-timeoffset/releases/download/v1.1/ctr-no-timeoffset.3dsx"

echo "Downloading universal-otherapp"
wget -q "https://github.com/TuxSH/universal-otherapp/releases/download/v1.3.0/otherapp.bin" # I do not think this is gonna get many updates, if it starts updating a lot I'll use the api

echo "Downloading boot9strap"
wget -q "https://github.com/SciresM/boot9strap/releases/download/1.3/boot9strap-1.3.zip" # Has not been updated since 2017, should be no reason to call the api

echo "Downloading SafeB9SInstaller"
wget -q "https://github.com/d0k3/SafeB9SInstaller/releases/download/v0.0.7/SafeB9SInstaller-20170605-122940.zip" # Same reason as above

echo "Downloading Homebrew Launcher Wrapper" # is this just a blank cia to use as a forwarder?
wget -q "https://github.com/PabloMK7/homebrew_launcher_dummy/releases/download/v1.0/Homebrew_Launcher.cia" # Same reason as above

echo "Downloading Checkpoint"
wget -q "https://github.com/FlagBrew/Checkpoint/releases/download/v3.7.4/Checkpoint.cia" # Using older release for now as newer one broke:tm:

#####################
# make some folders #
#####################
echo "Creating directories for each catalyst"
mkdir -p {soundhax/3ds,soundhax/cias,soundhax/boot9strap,soundhax/luma/payloads} # saves me the slightest bit of time later
mkdir -p {usm/3ds,usm/cias,usm/luma/payloads}
mkdir -p {pichaxx/3ds,pichaxx/cias,pichaxx/boot9strap,pichaxx/luma/payloads}

echo "Creating output dir"
mkdir out

####################
# Do the unzipping #
####################
echo "Do the unzipping"
unzip -q Luma3DSv*.zip;rm Luma3DSv*.zip
mkdir tmp;mv GodMode9*.zip tmp;cd tmp/;unzip -q *.zip;mv GodMode9.firm ..; mv -f gm9 ..;cd ..;rm -rf tmp
unzip -q boot9strap-1.3.zip;rm boot9strap-1.3.zip
mkdir tmp;mv SafeB9SInstaller*.zip tmp;cd tmp/;unzip -q *.zip;mv SafeB9SInstaller.bin ..;cd ..;rm -rf tmp
unzip -q Frogminer_save.zip;rm Frogminer_save.zip
mkdir tmp;mv release_6.0.1.zip tmp;cd tmp/;unzip -q *.zip;mv release_6.0.1/boot.nds ..;cd ..;rm -rf tmp

################
# yay soundhax #
################
echo "Putting soundhax related files in correct locations"
cp *.cia soundhax/cias
cp *.3dsx soundhax/3ds
mv soundhax/3ds/boot.3dsx soundhax/boot.3dsx
cp otherapp.bin soundhax
cp boot.firm soundhax/boot.firm
cp GodMode9.firm soundhax/luma/payloads
cp -r gm9 soundhax/gm9
cp boot9strap.* soundhax/boot9strap
cp SafeB9SInstaller.bin soundhax
cd soundhax
zip -r soundhax.zip * 
mv soundhax.zip ../out
cd ..
rm -rf soundhax

####################
# methax? pichaxx? #
####################
echo "Putting pichaxx related files in correct locations"
cp *.cia pichaxx/cias
cp *.3dsx pichaxx/3ds
mv pichaxx/3ds/boot.3dsx pichaxx/boot.3dsx
mv otherapp.bin pichaxx
cp boot.firm pichaxx/boot.firm
cp GodMode9.firm pichaxx/luma/payloads
cp -r gm9 pichaxx/gm9
mv boot9strap.* pichaxx/boot9strap
mv SafeB9SInstaller.bin pichaxx
cd pichaxx
zip -r pichaxx.zip * 
mv pichaxx.zip ../out
cd ..
rm -rf pichaxx

################################
# unsafe mode is actually safe #
################################
echo "Putting USM related files in correct locations"
mv *.cia usm/cias
mv *.3dsx usm/3ds
mv usm/3ds/boot.3dsx usm/boot.3dsx
mv boot.firm usm/boot.firm
mv GodMode9.firm usm/luma/payloads
mv gm9 usm/gm9
cd usm
zip -r usm.zip * 
mv usm.zip ../out
cd ..
rm -rf usm

###########
# md5sums #
###########
for cum in out/*
do
    md5sum "$cum" > "$cum.md5"
done

###########
# Credits #
###########
# One liner to download latest release: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-2724872
# My friend Logan for being in voice with my while not doing his school work
# Will Stetson for making the music I am listening to while doing this https://www.youtube.com/watch?v=8daZtdrFmBY
# My friend Brandon's DS that had a broken start button making it so I had to use browserhax and add the second zip file
# Lifehacker for copying this script and adding a few other methods (which I then stole)
# My boyfriend for letting me use him as a pillow a few times a week to keep me alive
