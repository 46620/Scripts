########################################
# THIS WAS STOLEN FROM MY NX SCRIPT!!  #
########################################

###################
# Fucking kill me #
###################
mkdir -p tmp/{3ds,cias,luma/payloads} # saves me the slightest bit of time later
cd tmp
export script_start=`pwd`
########
# Luma #
########
echo "Downloading Luma"
curl -sL -H "Authorization: token $ghtoken" https://api.github.com/repos/LumaTeam/Luma3DS/releases/latest | jq -r '.assets[0].browser_download_url' | wget -i -
unzip Luma3DSv*.zip
rm Luma3DSv*.zip

#################
# Homebrew apps #
#################

echo "Downloading FBI" # might swap this out for the fork ngl
curl -sL -H "Authorization: token $ghtoken" https://api.github.com/repos/Steveice10/FBI/releases/latest | jq -r '.assets[].browser_download_url' | wget -i -
rm -rf FBI.zip

echo "Downloading Anemone"
curl -sL -H "Authorization: token $ghtoken" https://api.github.com/repos/astronautlevel2/Anemone3DS/releases/latest | jq -r '.assets[1].browser_download_url' | wget -i -

echo "Downloading ftpd"
curl -sL -H "Authorization: token $ghtoken" https://api.github.com/repos/mtheall/ftpd/releases/latest | jq -r '.assets[0].browser_download_url' | wget -i -

echo "Downloading Checkpoint"
curl -sL -H "Authorization: token $ghtoken" https://api.github.com/repos/FlagBrew/Checkpoint/releases/latest | jq -r '.assets[1].browser_download_url' | wget -i -

echo "Downloading Universal Updater"
curl -sL -H "Authorization: token $ghtoken" https://api.github.com/repos/Universal-Team/Universal-Updater/releases/latest | jq -r '.assets[1].browser_download_url' | wget -i -

echo "Downloading Homebrew Launcher Wrapper" # is this just a blank cia to use as a forwarder?
curl -sL -H "Authorization: token $ghtoken" https://api.github.com/repos/mariohackandglitch/homebrew_launcher_dummy/releases/latest | jq -r '.assets[].browser_download_url' | wget -i -

echo "Downloading GodMode9"
curl -sL -H "Authorization: token $ghtoken" https://api.github.com/repos/d0k3/GodMode9/releases/latest | jq -r '.assets[].browser_download_url' | wget -i -
mkdir tmp;mv GodMode9*.zip tmp;cd tmp/;unzip *.zip;mv GodMode9.firm ../luma/payloads;cd ..;rm -rf tmp

echo "Downloading DSP1"
wget "https://github.com/zoogie/DSP1/releases/download/v1.0/DSP1.cia" # Not updated since 2017 so not gonna do an API call

echo "Downloading crt-no-timeoffset" # Not updated since 2019 so not gonna do an API call
wget "https://github.com/ihaveamac/ctr-no-timeoffset/releases/download/v1.1/ctr-no-timeoffset.3dsx"

################
# Moving shit  #
################

echo "Putting homebrew files in correct locations"
mv *.cia cias
mv *3dsx 3ds
mv 3ds/boot.3dsx $script_start

###########
# Archive #
###########
echo "Create zip archive"
mkdir ../out
7z a -tzip "../out/latest.zip" *

###########
# Credits #
###########
# One liner to download latest release: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-2724872
# My friend Logan for being in voice with my while not doing his school work
# Will Stetson for making the music I am listening to while doing this https://www.youtube.com/watch?v=8daZtdrFmBY
# My boyfriend for letting me use him as a pillow a few times a week to keep me alive