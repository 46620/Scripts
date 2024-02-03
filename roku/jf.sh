#!/bin/bash

# This script is meant for automating a Jellyfin update to the latest -git
# This was mostly to deal with AV1 not working on a Roku, cause fuck Roku

#set -x
set -euo pipefail

function vars(){
    readonly ROKU_IP= # Your Roku IP (REQUIRED)
    readonly ROKU_PASS= # Your Roku dev PW (REQUIRED)
    readonly IS_TRANS=0 # Use trans flag logos (OPTIONAL)

    # Validate vars
    if [ -z "$ROKU_IP" ]
    then
        echo "Roku IP is not set, please edit the script and add the required variables"
        exit 1
    fi

    if [ -z "$ROKU_PASS" ]
    then
        echo "Roku PASS is not set, please edit the script and add the required variables"
        exit 1
    fi
}

function check_power(){
    clear
    echo " [ * ] Checking if the Roku is on, and turning it on if not"
    set +e
    curl http://$ROKU_IP:8060/query/device-info | grep DisplayOff
    if [ $? -eq 0  ]
    then
        echo " [ * ] Turning Roku on"
        curl -m 1 -XPOST http://$ROKU_IP:8060/keypress/power
        set -e
    else
        echo " [ * ] Roku already on"
        set -e
    fi
}

function build_jf(){
    echo " [ * ] Building Jellyfin"
    cd /tmp
    rm -rf jellyfin-roku # Just in case a build ran before, luckily doesn't throw error 1 so it can stay
    git clone --recursive https://github.com/jellyfin/jellyfin-roku.git
    cd jellyfin-roku
    if [ $IS_TRANS -eq 1 ]
    then
        echo " [ * ] Transing your Jellyfin"
        rm -rf /tmp/trans_jf.zip
        wget -O /tmp/trans_jf.zip https://dl.46620.moe/trans_jf.zip
        cd images
        unzip -o /tmp/trans_jf.zip
        cd ..
    fi
    ROKU_DEV_TARGET=$ROKU_IP ROKU_DEV_PASSWORD=$ROKU_PASS make install
    echo " [ * ] Turning Roku off"
    curl -m 1 -XPOST http://$ROKU_IP:8060/keypress/power # OH BUT THIS ONE FUCKING WORKS?
}

function main(){
    vars
    check_power
    build_jf
}

main