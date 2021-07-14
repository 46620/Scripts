########################################
#  PS VITA/TV CLEAN SD/RESTORE SCRIPT  #
########################################

########
# Info #
########
# I went into this wanting to make a bunch of packs for each version, I then decided fuck it, one pack. I spent ~3 hours working on trying to make sure every version worked


###############
# Make folders#
###############

echo "Creating the folders"
mkdir -p {vita/{vpks,tai},pc}

#################
# Recovery 3.65 #
#################

echo "Downloading 3.65"
wget -O "pc/PSP2UPDAT.PUP" "https://web.archive.org/web/20180630222648id_/http://dus01.psp2.update.playstation.net/update/psp2/image/2017_0317/rel_0a0f2a9ae58968ac5d1d2127049c3cba/PSP2UPDAT.PUP"

echo "Downloading h-encore and the extra stuff for it"
wget -O "pc/h-encore.7z" "https://github.com/soarqin/finalhe/releases/download/v1.92/FinalHE_v1.92_win32.7z"
wget -O "pc/qcmadriver.exe" "https://github.com/soarqin/finalhe/releases/download/v1.91/QcmaDriver_winusb.exe"

###############
# Actual Shit #
###############

echo "Downloading enso"
wget -O "vita/vpks/enso.vpk" "https://github.com/henkaku/enso/releases/download/v1.1/enso.vpk"
# Shit is archived on github, might use a fork in the future

echo "Downloading vitashell"
wget -O "vita/vpks/vitashell.vpk" "https://github.com/TheOfficialFloW/VitaShell/releases/download/v2.02/VitaShell.vpk"
# Has not updated in over a year, if it updates I'll change it back to an API call

echo "Downloading config.txt"
wget -O "tai/config.txt" "https://vita.hacks.guide/assets/files/config.txt"

# Nothing below updates, just pull and don't use API

echo "Downloading NoNpDrm"
wget -O "tai/nonpdrm.skprx" "https://github.com/TheOfficialFloW/NoNpDrm/releases/download/v1.2/nonpdrm.skprx"

echo "Downloading 0syscall6" 
wget -O "vita/tai/0syscall6.skprx" "https://github.com/SKGleba/0syscall6/releases/download/v1.3/0syscall6.skprx"

echo "Downloading Download Enabler"
wget -O "vita/tai/download_enabler.suprx" "https://github.com/TheOfficialFloW/VitaTweaks/releases/download/DownloadEnabler/download_enabler.suprx"

echo "Downloading shellbat"
wget -O "vita/tai/shellbat.suprx" "https://github.com/nowrep/vita-shellbat/releases/download/r10/shellbat.suprx"

echo "Downloading pngshot"
wget -O "vita/tai/pngshot.suprx" "https://github.com/xyzz/pngshot/releases/download/v1.3/pngshot.suprx"

echo "Downloading PSVshell"
wget -O "vita/tai/PSVshell.skprx" "https://github.com/Electry/PSVshell/releases/download/v1.1/PSVshell.skprx"

#####################
# Make the archives #
#####################
7z a -tzip "out/latest.zip" *

###########
# Credits #
###########
# One liner to download latest release: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8#gistcomment-2724872
# PhazonicRidley for telling me to actually work on this before the wiiu one.
# My friend Ramon back in 2018 when I helped him hack his VITA, I remembered that one night and now I am working on this script
# https://www.youtube.com/watch?v=IZ4kbzxKyNo
# My boyfriend for letting me use him as a pillow almost daily to keep me alive