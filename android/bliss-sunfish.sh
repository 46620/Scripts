#!/bin/bash

# Oh boy here we go again

# Script goes in docker container to build bliss for sunfish

#repo sync -c --force-sync --no-tags --no-clone-bundle -j$(nproc --all) --optimized-fetch --prune
source ./build/envsetup.sh
blissify -g sunfish