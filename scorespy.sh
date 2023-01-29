#!/bin/bash

# Quick dirty script to modify the ScoreSpy AppImage to allow obs-vkcapture to work on Linux
# There shouldn't be a ban risk, as there's no modifications to the game files themselves
set -e
if [ !  -f "$1" ]; then
    program_name=${0##*/}
    echo "Usage: $program_name <scorespy appimage>"
fi

echo "Extracting AppImage"
SSPATH=$(dirname "$1")
cd "$SSPATH"
"$1" --appimage-extract
sed -i 's@exec "$BIN"@OBS_VKCAPTURE=1 obs-gamecapture "$BIN"@g' squashfs-root/AppRun
wget "https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage"
chmod +x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage squashfs-root
rm appimagetool-x86_64.AppImage
echo "AppImage has been modified to support obs-vkcapture"