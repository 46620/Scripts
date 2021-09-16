#!/bin/bash

# run with sudo, tested on ubuntu (running in docker container)

echo STOPPING PLEX
docker stop Plex

echo UPDATING anilist
cd '/opt/plexmediaserver/config/Library/Application Support/Plex Media Server/Plug-ins/anilist.bundle'
git reset --hard && git pull
chmod 775 -R '/opt/plexmediaserver/config/Library/Application Support/Plex Media Server/Plug-ins/anilist.bundle'

echo UPDATING Absolute Series Scanner
wget -O '/opt/plexmediaserver/config/Library/Application Support/Plex Media Server/Scanners/Series/Absolute Series Scanner.py' https://raw.githubusercontent.com/ZeroQI/Absolute-Series-Scanner/master/Scanners/Series/Absolute%20Series%20Scanner.py
chmod 775 -R '/opt/plexmediaserver/config/Library/Application Support/Plex Media Server/Scanners'

echo STARTING PLEX
docker start Plex
