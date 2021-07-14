@echo off
:: This script converts any file shoved into it to mp3 where the script is called. This is meant for drag and drop but can be put into PATH and called anytime

ffmpeg -i %1 "%~nx1.mp3"