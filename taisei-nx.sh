#!/bin/bash
# This script will assume you have all build deps install already, please install them before using this

git clone --recursive https://github.com/taisei-project/taisei.git
cd taisei
mkdir -p ./build/nx
./switch/crossfile.sh > ./build/nx/crossfile.txt
meson --prefix=`pwd`/build/nx/switch --cross-file="./build/nx/crossfile.txt" . ./build/nx
ninja -C ./build/nx
ninja install -C ./build/nx
zip -r taisei-nx.zip build/nx/switch/
