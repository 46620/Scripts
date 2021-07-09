:: Script by 46620
:: When I show borrowed code from stackoverflow I will link it in a comment

:: TODO
:: Allow the user to pass a path and a file with all the flags
:: Make it so it can take either 0 or 2 inputs, but not 1
:: Find a cleaner way to do this as the current method is actually very gross and is painful
:: Figure out a way to implement installing/updating ffmpeg
:: Find a way to add hw accel

: Script launch
@echo off
color 0a

: menu
clear
title FFMPEG AIO v0.0.1
echo What would you like to do today:
echo Please note that none of this script is tested. This warning will go away when it was actually tested.
echo
echo 1. Encode videos
echo 2. Encode audios (mp3 only for now)
echo 99. Update the script
echo 0. Install/update ffmpeg (NOT IMPLEMENTED)
echo

set /P menu=Choose a number from above: 
IF %menu%==1 goto video_encoder
if %menu%==2 goto audio_only_bitrate
IF %menu%==99 goto scriptupdate
IF %menu%==0 goto ffmpegupdate
goto menu
exit

: video_encoder
clear
set is_video=1
echo What would you like to encode to:
echo
echo 1. Encode to h264
echo 2. Encode to h265 (recommended)
echo 3. Encode to AV1 (not recommended)
echo
set /P video_encode=Choose a number from above: 
goto video_encoder_set

: video_bitrate
clear
set /P video_bitrate=What would you like the video bitrate to be (in kbps): 
goto audio_type
:: TODO add a check to make sure it's only a number
REM goto video_bitrate_check

: audio_type
clear
echo What audio format do you want to use?
echo
echo 1. AAC
echo 2. Opus (recommended)
echo 3. MP3 (not recommended)
echo
set /P audio_encode=Choose a number from above: 
goto audio_encoder_set 
exit

: audio_bitrate
clear
set /P audio_bitrate=What would you like the video bitrate to be (in kbps): 
goto set_path
:: TODO add a check to make sure it's only a number
REM goto audio_bitrate_check

: audio_only_bitrate
set is_video=0
set /P audio_bitrate=What would you like the video bitrate to be (in kbps): 
goto set_path


: set_path
set /P folder=Please drag and drop the folder here and hit enter:
cd /D %folder%
IF %is_video%==1 goto video_flag_check
IF %is_video%==0 goto encode

: video_flag_check
clear
echo Please make sure the following are correct
echo Video Encoder: %video_encoder%
echo Video Bitrate: %video_bitrate%
echo Audio Format: %audio_encoder%
echo Audio Bitrate: %audio_bitrate%

set /P video_flag_check=Are the above correct? (y/n): 
IF %video_flag_check%==y goto final_check
IF %video_flag_check%==n goto video_flag_check_wrong

: final_check
set /P extra_flags=Please add extra flags here (Press enter for none): 
goto encode


: video_flag_check_wrong
clear
echo This script will put you back to the start, please enter everything correctly
goto video_encoder
exit

: encode
IF %is_video%==1 goto vid_encode
IF %is_video%==0 goto aud_encode

: vid_encode
mkdir output
for %%a in (*) DO ffmpeg -i "%%a" -map 0 -c:v %video_encoder% -b:v %video_bitrate%k -c:a %audio_encoder% -b:a %audio_bitrate%k "output\%~na_cut.mkv"

: aud_encode
for %%a in (*) DO ffmpeg -i "%%a" -b:a "%%~nx.mp3"



:: Setting and checking flags to make sure shit is right

: video_encoder_set
IF %video_encode%==1 set video_encoder=libx264
IF %video_encode%==2 set video_encoder=libx265
IF %video_encode%==3 set video_encoder=libaom-av1
goto video_bitrate
exit

: video_bitrate_check
echo Ending up here would be confusing ngl, no check is implemented yet so this section is useless.
pause
exit

: audio_encoder_set
IF %audio_encode%==1 set audio_encoder=aac
IF %audio_encode%==2 set audio_encoder=libopus
IF %audio_encode%==3 set audio_encoder=libmp3lame
goto audio_bitrate
exit

: audio_bitrate_check
echo Ending up here would be confusing ngl, no check is implemented yet so this section is useless.
pause
exit

:: Special Options

: scriptupdate
title Update the script
echo Downloading latest version of the script, Please wait...
%SystemRoot%\system32\ping.exe -n 1 github.com >nul
if errorlevel 1 goto offline

powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/46620/Scripts/master/windows/ffmpeg/ffmpeg-aio.bat', 'ffmpeg-aio.bat')"
goto menu
exit

: ffmpegupdate
title Install/update ffmpeg
echo Installing/updating FFMPEG, please wait...
%SystemRoot%\system32\ping.exe -n 1 github.com >nul
if errorlevel 1 goto offline

cmd ffmpeg-installer.bat
goto menu
exit

: offline
echo Script could not connect to github, this function is disabled.
goto menu
exit
