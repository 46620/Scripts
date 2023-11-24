@echo off

REM ZERO SUPPORT GIVEN! I DON'T USE WINDOWS
@set scriptver=1.7.13
color 0a

REM Metadata
title 46620 Yuzu Setup Script V%scriptver%

REM I have not written a batch script in literal fucking years, so sorry for what is about to happen
REM I stole the fw version getting line from pbanj, as he already made one and it seems to work fine
REM Also fuck batch I hate it, fuck powershell, fuck windows, use Linux PLEASE

REM This script is missing the following features from the Linux build
REM Being written cleanly
REM Internet check
REM Firmware version to prevent updating already updated firmware

REM Set vars
:vars
cd /D %TMP%
set YUZU_DIR=%APPDATA%\yuzu
set PROD.KEYS=https://46620.moe/piracy.txt
REM this was written by pbanj
REM SWITCH FIRWMARE
for /f tokens^=1^,^2^,^3^,^4^,5^,6^,7^,8^,9^ skip^=^119 %%g in ('curl -s --raw  https://www.nintendo.com/my/support/switch/system_update/index.html') do (if /i "%%~j"=="version:" set fw=%%~k)
REM LIFTINSTALL VERSION (idk why they constantly update it)
for /f tokens^=1^,^2^,^3^,^4^ delims^=^"^ eol^=^, %%g in ('curl -s --raw  https://api.github.com/repos/yuzu-emu/liftinstall/releases/latest') do (if /i "%%~h"=="tag_name" set tag=%%~j)

set GITHUB_BASE_URL=https://raw.githubusercontent.com/46620/Scripts/master/yuzu/windows

REM Make directories for FW
REM This runs to make sure folders exist before downloading shit
:makefolders
mkdir %YUZU_DIR%\nand\system\Contents\registered
mkdir %YUZU_DIR%\keys

REM Get and install latest fw and prod.keys
:fwprod
curl -L -o %TMP%\firmware.zip https://archive.org/download/nintendo-switch-global-firmwares/Firmware%%20%fw%.zip
curl -L -o %TMP%\unzip.exe https://dl.46620.moe/unzip.exe
cd /D %YUZU_DIR%\nand\system\Contents\registered
del /Q *.nca
%TMP%\unzip.exe %TMP%\firmware.zip
curl -o %YUZU_DIR%\keys\prod.keys %PROD.KEYS%

REM Install yuzu
:installyuzu
curl -L -o %TEMP%\yuzu.exe "https://github.com/yuzu-emu/liftinstall/releases/download/%tag%/yuzu_install.exe"
%TEMP%\yuzu.exe
echo Press Enter when you install AND close yuzu
pause

REM The funny shit I am learning as I do it
:schtaskprompt
echo Would you like a scheduled task to update the firmware monthly?
echo This isn't required, but can help make future games work.
echo 1. Yes
echo 2. No
set /P A=Press 1 or 2 and then press Enter. 
if %A%==1 goto schtask
if %A%==2 goto noschtask
goto schtaskprompt
exit 

:schtask
REM This was helped by ChatGPT, as I do not wanna learn how schtasks work, so credit to whatever stack overflow articles it stole from
mkdir %APPDATA%\46620\yuzu
curl -L -o %APPDATA%\46620\yuzu\fw.vbs %GITHUB_BASE_URL%/fw.vbs
curl -L -o %APPDATA%\46620\yuzu\fw.cmd %GITHUB_BASE_URL%/fw.cmd
schtasks /create /tn YUZU_FW /tr %APPDATA%\46620\yuzu\fw.vbs /sc MONTHLY /st 16:00 /d 25 /mo 1 /F
echo Scheduled task is now created. PLEASE UPDATE %APPDATA%\46620\yuzu\fw.cmd's PROD.KEYS with your source of prod.keys, or remove the line entirely to not break yuzu every month
echo.
echo Press ENTER when you've read the above message
pause
goto end

:noschtask
goto end


:end
echo Yuzu should now be set up with the latest switch firmware. Please add your own prod.keys, as those are not provided for legal reasons
echo Press Enter to close the script
pause
exit

REM Credits
REM My friend Matt who I accidentally nuked the downloads folder of because we didn't know cd doesn't work through drives (taught me cd /D)