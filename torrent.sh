#!/bin/bash

# This script is to rename files that are in my semi private torrent.
# The hash will not be posted, don't ask me for it

echo "[ * ] Please note, this script was made to migrate the torrent. If you're downloading for the first time, you do not need this."
echo "      This script is also not usable with the perl version of rename, use the util-linux version instead."
echo "      This script shouldn't miss any files. If it does, please message @46620 on discord."
printf "%s " "Press enter to continue"
read ans

# 10c3fd to 6474c5
echo "[ * ] 10c3fd to 6474c5"
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

# 6474c5 to 04377e
echo "[ * ] 6474c5 to 04377e"
echo "      Nothing changed."

# 04377e to d5f4c0
echo "[ * ] 04377e to d5f4c0"
rename -va "Enen no Shouboutai - S01" "En'en no Shouboutai - S01" **
rename -va "Enen no Shouboutai - S02" "En'en no Shouboutai Ni no Shou - S02" **
mv "Enen no Shouboutai" "En'en no Shouboutai"
rename -va "Black Lagoon - S02" "Black Lagoon: The Second Barrage - S02" **
mv "Fullmetal Alchemist Brotherhood" "Hagane no Renkinjutsushi (2009)"
rename -va "Fullmetal Alchemist Brotherhood - S01" "Hagane no Renkinjutsushi (2009) - S01" **
rename -va "Kaguya-sama wa Kokurasetai Tensai-tachi no Ren'ai Zunousen - S01" "Kaguya-sama wa Kokurasetai: Tensai-tachi no Ren'ai Zunousen - S01" **
rename -va "Kaguya-sama wa Kokurasetai Tensai-tachi no Ren'ai Zunousen - S02" "Kaguya-sama wa Kokurasetai? Tensai-tachi no Ren'ai Zunousen - S02" **
mv "Kaguya-sama wa Kokurasetai Tensai-tachi no Ren'ai Zunousen" "Kaguya-sama wa Kokurasetai: Tensai-tachi no Ren'ai Zunousen"
rename -va "Kakegurui - S02" "Kakegurui XX - S02" **
rename -va "Kiniro Mosaic - S01" "Kin'iro Mosaic - S01" **
rename -va "Kiniro Mosaic - S02" Hello\!\!\ Kin\'iro\ Mosaic\ -\ S02 **
mv "Kiniro Mosaic" "Kin'iro Mosaic"
rename -va "Kobayashi-san Chi no Maid Dragon - S02" "Kobayashi-san Chi no Maidragon - S01" **
rename -va "Kobayashi-san Chi no Maid Dragon - S01" "Kobayashi-san Chi no Maidragon - S01" **
mv "Kobayashi-san Chi no Maid Dragon" "Kobayashi-san Chi no Maidragon"
rename -va New\ Game\!\ -\ S02 New\ Game\!\!\ -\ S02 **
rename -va "One Punch Man - S02" "One Punch Man (2019) - S02" **
rename -va "Ookami to Koushinryou - S02" "Ookami to Koushinryou II - S02" **
rename -va "Re Zero Kara Hajimeru Isekai Seikatsu - S02" "Re Zero Kara Hajimeru Isekai Seikatsu (2020) - S02" **
rename -va "Cromartie High School" Sakigake\!\!\ Cromartie\ Koukou **
rename -va "Yahari Ore no Seishun LoveCome wa Machigatte Iru. - S02" "Yahari Ore no Seishun LoveCome wa Machigatte Iru. Zoku - S02" **
rename -va "Yahari Ore no Seishun LoveCome wa Machigatte Iru. - S03" "Yahari Ore no Seishun LoveCome wa Machigatte Iru. Kan - S03" **
rename -va "Yuukoku no Moriarty - S02" "Yuukoku no Moriarty (2021) - S02" **
mv "Yuukoku no Moriarty/Season 01/Yuukoku no Moriarty - S01E08 - A Study in \"S\" Act 1.mkv" "Yuukoku no Moriarty/Season 01/Yuukoku no Moriarty - S01E08 - A Study in 'S' Act 1.mkv"
mv "Yuukoku no Moriarty/Season 01/Yuukoku no Moriarty - S01E09 - A Study in \"S\" Act 2.mkv" "Yuukoku no Moriarty/Season 01/Yuukoku no Moriarty - S01E09 - A Study in 'S' Act 2.mkv"
rename -va "Zombieland Saga - S01" "Zombie Land Saga - S01" **
rename -va "Zombie Land Saga - S02" "Zombie Land Saga Revenge - S02" **
mv "Zombieland Saga" "Zombie Land Saga"
rm "Pokemon/how many more temp files will Mia make"

# d5f4c0 to 04377e
echo "[ * ] d5f4c0 to 04377e"
echo "      Nothing changed to my knowledge."

# 04377e to 639c3c
echo "[ * ] 04377e to 639c3c"
echo "      Nothing changed to my knowledge."