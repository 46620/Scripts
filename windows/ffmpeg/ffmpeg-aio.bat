:: Script by 46620
:: When I show borrowed code from stackoverflow I will link it in a comment

: Script launch
@echo off
color 0a
title FFMPEG AIO v0

: menu
echo What would you like to do today?

echo 1. Encode to h264 (NOT IMPLEMENTED)
echo 2. Encode to h265 (NOT IMPLEMENTED)
echo 3. Encode to AV1 (NOT IMPLEMENTED)
echo 99. Update the script

set /P cum=Choose a number from above: 
IF %cum%==1 goto 1h264
IF %cum%==2 goto 1h265
IF %cum%==3 goto 1av1
IF %cum%==99 goto update
goto menu

: 1h264
echo Not added yet, come back later
goto menu

: 1h265
echo Not added yet, come back later
goto menu

: 1av1
echo Not added yet, come back later
goto menu

pause

: Update
echo Checking for Updates, Please wait...
%SystemRoot%\system32\ping.exe -n 1 github.com >nul
if errorlevel 1 goto offline

powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/46620/Scripts/master/windows/ffmpeg/ffmpeg-aio.bat', 'ffmpeg-aio.bat')" && goto menu
exit

: offline
echo Script is offline. Restarting to prevent an autodelete issue I have yet to fix
goto menu