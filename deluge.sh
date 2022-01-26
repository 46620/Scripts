#!/bin/bash

# what the fuck am I doing with my life
# Script to check if SSD is plugged in with USB --> SATA and starts seeding iso's if connected

uuid=B834-BA73
pkill deluged
deluged
while true
do
    if lsblk -f | grep -wq $uuid
    then
        if grep -qs '/mnt/iso ' /proc/mounts;
        then
            if [[ -f /tmp/deluge.pid ]]
            then
                echo "deluge already started"
                sleep 10
                continue
            else
                echo "start deluge"
                deluge-web -p 6069 -P /tmp/deluge.pid
            fi
        else
            echo "mount drive"
            mount /dev/disk/by-uuid/$uuid /mnt/iso
        fi
    else
        echo "killing deluge"
        umount -f /mnt/iso
        pkill deluge-web
        rm /tmp/deluge.pid
        sleep 10
    fi
done