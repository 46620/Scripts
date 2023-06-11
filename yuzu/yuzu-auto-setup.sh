#!/bin/bash

# This script will automate the setup of yuzu-ea on Linux devices, including the Steam Deck.

LATEST_FIRMWARE=`curl -s https://yls8.mtheall.com/ninupdates/feed.php | grep -m 1 "Switch" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+"`
YUZU_DIR="$HOME/.local/share/yuzu"
mkdir -p "$YUZU_DIR/nand/system/Contents/registered"
YUZU_FIRMWARE="$YUZU_DIR/nand/system/Contents/registered"
TMP_FIRM_NUM=`echo $LATEST_FIRMWARE | sed 's@\.@@g'`

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

echo " [ * ] Updating prod.keys"
# curl -o "$YUZU_DIR/keys/prod.keys" <PROVIDE YOUR OWN SOURCE! I DON'T WANT A DMCA>

echo " [ * ] Downloading and adding the latest AppImage to your Applications folder"
curl -s https://api.github.com/repos/pineappleEA/pineapple-src/releases/latest | jq -r ".assets[0] | .browser_download_url" | wget -qO "$HOME/Applications/yuzu.AppImage" -i -
chmod +x "$HOME/Applications/yuzu.AppImage"

echo " [ * ] Installing a systemd service and timer to auto update yuzu for you"
mkdir -p "$HOME/.config/systemd/user" 
mkdir -p "$HOME/.local/share/46620/yuzu"
cp -vr yuzu-update.{service,timer} "$HOME/.config/systemd/user"
cp -vr yuzu-update.sh "$HOME/.local/share/46620/yuzu"
systemctl --user enable yuzu-update.timer