#!/bin/bash

# Helper script for my discord patch

if [ "$(loginctl show-session "$XDG_SESSION_ID" -p Type --value)" = wayland ]; then
    /usr/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --app=https://canary.discord.com
else
    /usr/bin/chromium --app=https://canary.discord.com
fi