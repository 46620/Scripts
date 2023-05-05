#!/bin/bash

# This script is to rename files that are part of my semi private torrent. I will not give you the hash or post it publicly, find it on any of my socials that I post it on.

echo " [ * ] Please note, this script was made to migrate 10c3fd to 6474c5. You may not need this unless you're updating again in the future."
echo "       This script may also miss files, please do a manual check after and report if anything is missing."
echo "       Check the comments in the script to see what hash migration the renames are for."
read -n 1 -r -s -p $' Press Enter to continue\n'

set +e # Just in case I set this earlier, disable for the mv command to prevent it from breaking on a newer pack

# 10c3fd to 6474c5
shopt -s globstar
rename -va \` \' **
#rename -v "s@\`@'@" **

mv Amagi\ Brilliant\ Park/Specials/Amagi\ Brilliant\ Park\ OVA\ -\ No\ Time\ to\ Take\ it\ Easy\!.mkv Amagi\ Brilliant\ Park/Specials/Amagi\ Brilliant\ Park\ -\ S00E01\ -\ No\ Time\ to\ Take\ it\ Easy\!.mkv
mv "Charlotte/Specials/Charlotte - Ova1.mkv" "Charlotte/Specials/Charlotte - S00E01 - Strong People.mkv"
mv "Gabriel Dropout/Specials/Gabriel Dropout - OVA1.mkv" "Gabriel Dropout/Specials/Gabriel Dropout - S00E01 - Special 1.mkv"
mv "Gabriel Dropout/Specials/Gabriel Dropout - OVA2.mkv" "Gabriel Dropout/Specials/Gabriel Dropout - S00E02 - Special 2.mkv"
mv "Gakkou no Kaidan/Specials/Gakkou no Kaidan - Special 1 - The Headless Rider Curse of Death.mkv" "Gakkou no Kaidan/Specials/Gakkou no Kaidan - S00E01 - The Headless Rider Curse of Death.mkv"
mv "Kyoukai No Kanata/Specials/Kyoukai No Kanata Specials - 01 Shinonome.mkv" "Kyoukai No Kanata/Specials/Kyoukai No Kanata - S00E01 - Shinonome.mkv"
mv "Miru Tights/Specials/Miru Tights Specials - 01.mkv" "Miru Tights/Specials/Miru Tights Specials - S00E01 - Cosplay Shooting Tights.mkv"