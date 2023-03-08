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
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/Steveice10/FBI/releases/latest | jq -r '.assets[].browser_download_url' | wget -qi -
rm -rf FBI.zip

echo "Downloading Anemone"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/astronautlevel2/Anemone3DS/releases/latest | jq -r '.assets[1].browser_download_url' | wget -qi -

echo "Downloading Universal Updater"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/Universal-Team/Universal-Updater/releases/latest | jq -r '.assets[1].browser_download_url' | wget -qi -

echo "Downloading GodMode9"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/d0k3/GodMode9/releases/latest | jq -r '.assets[].browser_download_url' | wget -qi -

echo "Downloading unSAFE_MODE"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/zoogie/unSAFE_MODE/releases/latest | jq -r '.assets[0].browser_download_url' | wget -qi -

echo "Downloading universal-otherapp"
wget -q "https://github.com/TuxSH/universal-otherapp/releases/download/v1.4.0/otherapp.bin" # I do not think this is gonna get many updates, if it starts updating a lot I'll use the api

echo "Downloading boot9strap"
wget -q "https://github.com/SciresM/boot9strap/releases/download/1.4/boot9strap-1.4.zip" # Same reason as above

echo "Downloading SafeB9SInstaller"
wget -q "https://github.com/d0k3/SafeB9SInstaller/releases/download/v0.0.7/SafeB9SInstaller-20170605-122940.zip" # Same reason as above

echo "Downloading Homebrew Launcher Wrapper" # is this just a blank cia to use as a forwarder?
wget -q "https://github.com/PabloMK7/homebrew_launcher_dummy/releases/download/v1.0/Homebrew_Launcher.cia" # Same reason as above

echo "Downloading Checkpoint"
wget -q "https://github.com/FlagBrew/Checkpoint/releases/download/v3.7.4/Checkpoint.cia" # Using older release for now as newer one broke:tm:

echo "Downloading frogminer_save"
wget -q "https://github.com/zoogie/Frogminer/releases/download/v1.0/Frogminer_save.zip" # same reason as above

echo "Downloading b9sTool"
wget -q "https://github.com/zoogie/b9sTool/releases/download/v6.1.1/release_6.1.1.zip" # same reason as above

echo "Downloading BannerBomb3"
wget -q "https://github.com/lifehackerhansol/Bannerbomb3/releases/download/v3.0-lhs2/bb3.bin" # reading comprehension edition by lifehackerhansol:tm:

#####################
# make some folders #
#####################
echo "Creating directories for each catalyst"
mkdir -p {soundhax,usm,pichaxx,ntrboot,ssloth,fredtool} # saves me the slightest bit of time later

echo "Creating common directory"
mkdir -p common/{3ds,cias,boot9strap,luma/payloads}

echo "Creating output dir"
mkdir out

####################
# Do the unzipping #
####################
echo "Do the unzipping"
unzip -q Luma3DSv*.zip;rm Luma3DSv*.zip
mkdir tmp;mv GodMode9*.zip tmp;cd tmp/;unzip -q *.zip;mv GodMode9.firm ..; mv -f gm9 ..;cd ..;rm -rf tmp
unzip -q boot9strap-1.4.zip;rm boot9strap-1.4.zip
mkdir tmp;mv SafeB9SInstaller*.zip tmp;cd tmp/;unzip -q *.zip;mv SafeB9SInstaller.bin ..;mv SafeB9SInstaller.firm ..;cd ..;rm -rf tmp
mkdir tmp;mv RELEASE_v1.3.zip tmp;cd tmp/;unzip -q RELEASE_v1.3.zip;mv -f otherapps_with_CfgS ..;mv -f slotTool ..;mv -f usm.bin ..;cd ..;rm -rf tmp
unzip -q Frogminer_save.zip;rm Frogminer_save.zip
mkdir tmp;mv release_6.1.1.zip tmp;cd tmp/;unzip -q *.zip;mv boot.nds ..;cd ..;rm -rf tmp

#########################
# extract common things #
#########################
echo "Common directories"
mv *.cia common/cias
mv FBI.3dsx common/3ds/FBI.3dsx # I can't automate .3dsx batch copies, but also there's only one 3dsx so whatever
mv boot.3dsx common/boot.3dsx
mv boot.firm common/boot.firm
mv GodMode9.firm common/luma/payloads
mv -f gm9 common/gm9
mv boot9strap.* common/boot9strap

################
# yay soundhax #
################
echo "Putting soundhax related files in correct locations"
cp -r common/* soundhax
cp otherapp.bin soundhax
cp SafeB9SInstaller.bin soundhax
cd soundhax
zip -r soundhax.zip * 
mv soundhax.zip ../out
cd ..
rm -rf soundhax

##############################
# browserhax just won't die #
##############################
echo "Putting SSLoth-Browser related files in correct locations"
cp -r common/* ssloth
mv otherapp.bin ssloth/arm11code.bin
cp SafeB9SInstaller.bin ssloth
cd ssloth
zip -r ssloth.zip * 
mv ssloth.zip ../out
cd ..
rm -rf ssloth

####################
# methax? pichaxx? #
####################
echo "Putting pichaxx related files in correct locations"
cp -r common/* pichaxx
mv slotTool pichaxx/3ds/slotTool
mv otherapps_with_CfgS pichaxx/otherapps_with_CfgS
cp usm.bin pichaxx/usm.bin
cp SafeB9SInstaller.bin pichaxx
echo "!!! You must copy the corresponding *.bin file from the otherapps_with_CfgS folder for your console to the SD root,
and rename it to otherapp.bin.

The exploit will fail without it. !!!" > pichaxx/readme.txt
cd pichaxx
zip -r pichaxx.zip * 
mv pichaxx.zip ../out
cd ..
rm -rf pichaxx

################################
# unsafe mode is actually safe #
################################
echo "Putting USM related files in correct locations"
cp -r common/* usm
cp bb3.bin usm
mv usm.bin usm
mv SafeB9SInstaller.bin usm
cd usm
zip -r usm.zip * 
mv usm.zip ../out
cd ..
rm -rf usm

###################
# fwedtool is old #
###################
echo "Putting fredtool related files in correct locations"
cp -r common/* fredtool
mv bb3.bin fredtool
mv private fredtool/
mv boot.nds fredtool
cd fredtool
zip -r fredtool.zip * 
mv fredtool.zip ../out
cd ..
rm -rf fredtool

##################################
# pay 20USD for CFW with ntrboot #
##################################
echo "Putting ntrboot related files in correct locations"
mv -f common/* ntrboot
rm -rf common # cleanup
mv ntrboot/boot.firm ntrboot/luma/boot.firm
mv SafeB9SInstaller.firm ntrboot/boot.firm
echo "!!! boot.firm is the SafeB9Sinstaller. Once you have used it to install b9s successfully, you should delete it, and move boot.firm from the /luma folder onto the root folder. 

Your device will only boot to SafeB9Sinstaller until you do this. !!!" > ntrboot/readme.txt
cd ntrboot
zip -r ntrboot.zip * 
mv ntrboot.zip ../out
cd ..
rm -rf ntrboot

###########
# md5sums #
###########
for pack in out/*
do
    md5sum "$pack" > "$pack.md5"
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
