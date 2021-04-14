#!/bin/bash

# run with sudo, tested on ubuntu

echo STOPPING PLEX
systemctl stop plexmediaserver

echo UPDATING anilist
cd '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/anilist.bundle'
git reset --hard && git pull
chown -R plex:plex '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/anilist.bundle'
chmod 775 -R '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/anilist.bundle'

echo UPDATING Absolute Series Scanner
wget -O '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Scanners/Series/Absolute Series Scanner.py' https://raw.githubusercontent.com/ZeroQI/Absolute-Series-Scanner/master/Scanners/Series/Absolute%20Series%20Scanner.py
chown -R plex:plex '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Scanners'
chmod 775 -R '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Scanners'

echo STARTING PLEX
systemctl restart plexmediaserver
