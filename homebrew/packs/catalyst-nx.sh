#!/bin/bash
########################################
# Dear Nintendo, Due to recent DMCA's  #
# You filed on Github, I would like to #
# Say this script doesn't do anything  #
# To violate the DMCA, thank you <3    #
########################################

function firmware() {
    echo "Downloading CFW and bootloader"
    curl -sL -H "Authorization: token $ghtoken" https://api.github.com/repos/CTCaer/Hekate/releases/latest | jq -r '.assets[0].browser_download_url' | wget -qi -
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases | grep -wo "https.*.zip" | head -1 | wget -qi -
    unzip -q hekate*.zip
    unzip -q atmosphere*.zip
    rm hekate*.zip atmosphere*.zip
}

function configs() {
    echo "Downloading configs"
    mkdir -p atmosphere/hosts
    wget -qO atmosphere/hosts/emummc.txt "https://nh-server.github.io/switch-guide/files/emummc.txt"
    wget -qO bootloader/hekate_ipl.ini "https://suchmememanyskill.github.io/guides/Img/hekate_ipl.ini"
    wget -qO bootloader/patches.ini "https://suchmememanyskill.github.io/guides/Img/patches.ini"
    wget -O bootloader/bootlogo.bmp "https://cdn.discordapp.com/attachments/441119928334942218/939026586630512690/bootlogo.bmp"
    wget -q "https://nh-server.github.io/switch-guide/files/bootlogos.zip"
    unzip -q bootlogos.zip
    rm bootlogos.zip
}

function apps() {
    echo "Downloading Homebrew Apps"
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/retronx-team/mtp-server-nx/releases/latest | jq -r '.assets[0].browser_download_url' | wget -qO "switch/mtp-server-nx.nro" -i -
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/fortheusers/hb-appstore/releases/latest | grep -wo "https.*switch-extracttosd.zip" | wget -qi -
    unzip -q switch-extracttosd.zip;rm switch-extracttosd.zip
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/mtheall/ftpd/releases/latest | grep -wo "https.*.nro" | tail -1 | wget -qO "switch/ftpd.nro" -i -
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/XorTroll/Goldleaf/releases | grep -wo "https.*eaf.nro" | head -1 | wget -qO "switch/Goldleaf.nro" -i -
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/J-D-K/JKSV/releases | grep -wo "https.*.nro" | wget -qO "switch/JKSV.nro" -i -
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/FlagBrew/Checkpoint/releases/latest | jq -r '.assets[2].browser_download_url' | wget -qO "switch/Checkpoint.nro" -i -
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/joel16/NX-Shell/releases/latest | jq -r '.assets[].browser_download_url' | wget -qO "switch/NX-Shell.nro" -i -
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/exelix11/SwitchThemeInjector/releases/latest | jq -r '.assets[0].browser_download_url' | wget -qO "switch/NXThemesInstaller.nro" -i -
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/DarkMatterCore/nxdumptool/releases/latest | jq -r '.assets[].browser_download_url' | wget -qO "switch/nxdumptool.nro" -i -
    wget -qO switch/Switch_90DNS_tester.nro "https://github.com/meganukebmp/Switch_90DNS_tester/releases/download/v1.0.4/Switch_90DNS_tester.nro"
}

function payloads() {
    echo "Downloading Payloads"
    curl -L https://vps.suchmeme.nl/git/api/v1/repos/mudkip/Lockpick_RCM/releases | jq -r | grep browser_download_url | cut -b 33- | tr -d '"' | wget -qO "bootloader/payloads/Lockpick_RCM.bin" -i -
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/suchmememanyskill/TegraExplorer/releases/latest | jq -r '.assets[].browser_download_url' | wget -qO "bootloader/payloads/TegraExplorer.bin" -i -
    curl -sLq -H "Authorization: token $ghtoken" https://api.github.com/repos/Atmosphere-NX/Atmosphere/releases | grep -wo "https.*.bin" | head -1 | wget -q "bootloader/payloads/fusee.bin" -i -
    echo "Making hekate reboot_payload.bin"
    cp hekate*.bin bootloader/payloads/hekate.bin
    mv hekate*.bin atmosphere/reboot_payload.bin
}

function archive(){
    echo "Create zip archive"
    7z a -tzip "out/latest.zip" * > /dev/null
    cd out
    md5sum "latest.zip" > "latest.zip.md5"
}

main() {
    firmware
    configs
    apps
    payloads
    archive
}

main "$@"

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
