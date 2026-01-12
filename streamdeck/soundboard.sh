#!/bin/bash

# No fucking soundboard plugin was working for me how I want so I am going to make a tiny little POS for this

# This script is for my setup only, this is purely a backup. make it work for your own or wait like a year when I make it a tiny bit modular

VOLUME="${2:-100}"  # If $2 is not set, set volume to 100
echo $VOLUME
DEFAULT_AUDIO="$(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep 'node.name' | cut -d'"' -f2)"
pw-cli create-node adapter "{ factory.name=support.null-audio-sink node.name "Soundboard" media.class=Audio/Sink object.linger=true audio.position=[MONO] }"
pw-link "Soundboard:monitor_MONO" "$DEFAULT_AUDIO:playback_FL"
pw-link "Soundboard:monitor_MONO" "$DEFAULT_AUDIO:playback_FR"
pw-link "Soundboard:monitor_MONO" "WEBRTC VoiceEngine:input_MONO"
PIPEWIRE_NODE=Soundboard mpv --volume="$VOLUME" "$1"  # Plays arg1 as audio and arg2 as volume
pw-cli d "Soundboard"