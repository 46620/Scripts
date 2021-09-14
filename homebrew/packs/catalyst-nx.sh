#!/bin/bash
########################################
# THIS WILL NOT DOWNLOAD SIG PATCHES!  #
########################################

#######################
# Hekate & Atmosphere #
#######################
echo "Downloading Hekate"
curl -sL -H "Authorization: token $ghtoken" https://api.github.com/repos/CTCaer/Hekate/releases/latest | jq -r '.assets[0].browser_download_url' | wget -qi -
echo "Adding Hekate"
unzip -q hekate*.zip
rm hekate*.zip

echo "Downloading Atmosphere"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases | grep -wo "https.*.zip" | head -1 | wget -qi -
echo "Adding Atmosphere"
unzip -q atmosphere*.zip
rm atmosphere*.zip

###############
# Guide Files #
###############
echo "Downloading hosts file"
mkdir -p atmosphere/hosts
wget -qO atmosphere/hosts/emummc.txt "https://nh-server.github.io/switch-guide/files/emummc.txt"

echo "Downloading hekate files from meem" # Can be swapped out for guide files
wget -qO bootloader/hekate_ipl.ini "https://raw.githubusercontent.com/suchmememanyskill/suchmememanyskill.github.io/master/guides/Img/hekate_ipl.ini"
wget -qO bootloader/patches.ini "https://suchmememanyskill.github.io/guides/Img/patches.ini"

echo "Downloading boot logos" # Cause people need these for some fucking reason
wget -q "https://nh-server.github.io/switch-guide/files/bootlogos.zip"
unzip -q bootlogos.zip
rm bootlogos.zip

#################
# Homebrew Apps #
#################

echo "Adding nx-mtp"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/retronx-team/mtp-server-nx/releases/latest | jq -r '.assets[0].browser_download_url' | wget -qO "switch/mtp-server-nx.nro" -i -

echo "Adding hb_appstore"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/fortheusers/hb-appstore/releases/latest | jq -r '.assets[2].browser_download_url' | wget -qi -
unzip -q switch-extracttosd.zip;rm switch-extracttosd.zip

echo "Adding ftpd"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/mtheall/ftpd/releases/latest | jq -r '.assets[12].browser_download_url' | wget -qO "switch/ftpd.nro" -i -

echo "Adding Goldleaf"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/XorTroll/Goldleaf/releases | grep -wo "https.*eaf.nro" | head -1 | wget -qO "switch/Goldleaf.nro" -i -

echo "Adding Checkpoint"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/FlagBrew/Checkpoint/releases/latest | jq -r '.assets[2].browser_download_url' | wget -qO "switch/Checkpoint.nro" -i -

echo "Adding NX-Shell"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/joel16/NX-Shell/releases/latest | jq -r '.assets[].browser_download_url' | wget -qO "switch/NX-Shell.nro" -i -

echo "Adding NXThemeInstaller"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/exelix11/SwitchThemeInjector/releases/latest | jq -r '.assets[0].browser_download_url' | wget -qO "switch/NXThemesInstaller.nro" -i -

echo "Adding nxdumptool"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/DarkMatterCore/nxdumptool/releases/latest | jq -r '.assets[].browser_download_url' | wget -qO "switch/nxdumptool.nro" -i -

echo "Adding 90dns tester"
wget -qO switch/Switch_90DNS_tester.nro "https://github.com/meganukebmp/Switch_90DNS_tester/releases/download/v1.0.3/Switch_90DNS_tester.nro"

################
# Payload Shit #
################

echo "Adding Lockpick_RCM" # This is the lockpicking lawyer
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/shchmue/Lockpick_RCM/releases/latest | jq -r '.assets[].browser_download_url' | wget -qO "bootloader/payloads/Lockpick_RCM.bin" -i -

echo "Adding TegraExplorer" 
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/suchmememanyskill/TegraExplorer/releases/latest | jq -r '.assets[].browser_download_url' | wget -qO "bootloader/payloads/TegraExplorer.bin" -i -

echo "Adding fusee payload"
curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases | grep -wo "https.*.bin" | head -1 | wget -q "bootloader/payloads/fusee.bin" -i -

echo "Add Hekate to payloads"
cp hekate*.bin bootloader/payloads/hekate.bin

echo "Make Hekate reboot_payload"
mv hekate*.bin atmosphere/reboot_payload.bin

#############
# Frii logo #
#############
# echo Adding bootlogo
# update 2021-09-06, ams 1.0 made this section not needed and as I am currently fixing this script before nh says anything, I am removing this until notified
#wget -O bootloader/bootlogo.bmp "https://46620.moe/bootlogo.bmp"

###########
# Archive #
###########
echo "Create zip archive"
7z a -tzip "out/latest.zip" * > /dev/null
cd out
md5sum "latest.zip" > "latest.zip.md5"

###########
# Credits #
###########
# One liner to download latest release: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-2724872
# PhazonicRidley for telling me I should set this back up: https://gitlab.com/PhazonicRidley
# Nintendo Homebrew for using this as their catalyst pack: https://discord.gg/C29hYvh
# Cruzmatt22 for being in voice chat: https://images-na.ssl-images-amazon.com/images/I/71hcpuNp7gL._SY445_.jpg
# Windows 10 for being shit and somehow causing my internet to constantly go down: https://www.microsoft.com/en-us/
# My computer for constantly BSoD'ing cause I have some memory issues while I try to not make this script bad
# My brain for figuring out "Oh hey lemme set the path in the actual one liner"
# ams for updating to 1.0 finally and making me rework some of my script.
# My boyfriend for letting me use him as a pillow a few times a week to keep me alive
