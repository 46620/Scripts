#!/bin/bash

# run with sudo, tested on ubuntu

echo STOPPING PLEX
docker stop Plex

echo UPDATING HAMA
cd '/opt/plexmediaserver/config/Library/Application Support/Plex Media Server/Plug-ins/Hama.bundle'
git reset --hard && git pull
chown -R plex:plex '/opt/plexmediaserver/config/Library/Application Support/Plex Media Server/Plug-ins/Hama.bundle'
chmod 775 -R '/opt/plexmediaserver/config/Library/Application Support/Plex Media Server/Plug-ins/Hama.bundle'

echo UPDATING Absolute Series Scanner
wget -O '/opt/plexmediaserver/config/Library/Application Support/Plex Media Server/Scanners/Series/Absolute Series Scanner.py' https://raw.githubusercontent.com/ZeroQI/Absolute-Series-Scanner/master/Scanners/Series/Absolute%20Series%20Scanner.py
chown -R plex:plex '/opt/plexmediaserver/config/Library/Application Support/Plex Media Server/Scanners'
chmod 775 -R '/opt/plexmediaserver/config/Library/Application Support/Plex Media Server/Scanners'

echo STARTING PLEX
docker start Plex
