#!/bin/bash

# PLEASE DO NOT RUN THIS SCRIPT ON IT'S OWN, IT'S ONLY MEANT FOR SYSTEMD USE

ping -c 1 -W 5 8.8.8.8
if ! [ $? -eq 0 ]; then
    echo "uhhhhh there is no internet, take off your clothes"
    exit 1
fi

readonly YUZU_DIR="$HOME/.local/share/yuzu"
mkdir -p "$YUZU_DIR/nand/system/Contents/registered"

# Set this to 1 to download the latest switch firmware
# Please note that this will add up to 10-40 minutes to the execution time of the script if there is an update
readonly DOWNLOAD_FIRMWARE=1
readonly LATEST_FIRMWARE=`curl -s https://yls8.mtheall.com/ninupdates/feed.php | grep -m 1 "Switch" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+"`
readonly YUZU_FIRMWARE="$YUZU_DIR/nand/system/Contents/registered"
readonly TMP_FIRM_NUM=`echo $LATEST_FIRMWARE | sed 's@\.@@g'`

if [[ $DOWNLOAD_FIRMWARE -eq 1 ]]
then 
    echo " [ * ] Checking switch firmware"
    if [[ $TMP_FIRM_NUM -eq `cat $YUZU_DIR/firmware.txt | sed 's@\.@@g'` ]]
    then
        echo " [ * ] Firmware is up to date, no updates needed"
    else
        echo " [ * ] Downloading and installing latest switch firmware (This can take around 10 minutes depending on your connection to the Internet Archive)"
        rm -rvf $YUZU_FIRMWARE/*.nca
        curl --output -  -s -L https://archive.org/download/nintendo-switch-global-firmwares/Firmware%20$LATEST_FIRMWARE.zip | bsdtar -xvf - -C $YUZU_FIRMWARE
        echo $LATEST_FIRMWARE > $YUZU_DIR/firmware.txt
    fi
fi

echo " [ * ] Updating prod.keys"
# curl -o "$YUZU_DIR/keys/prod.keys" <PROVIDE YOUR OWN SOURCE! I DON'T WANT A DMCA>

echo " [ * ] Downloading and adding the latest AppImage to your Applications folder"
curl -s https://api.github.com/repos/pineappleEA/pineapple-src/releases/latest | jq -r ".assets[0] | .browser_download_url" | wget -qO "$HOME/Applications/yuzu.AppImage" -i -
chmod +x "$HOME/Applications/yuzu.AppImage"