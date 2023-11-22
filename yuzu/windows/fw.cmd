@echo off
title YUZU_FW_UPDATER
echo Sorry that this window pops on the task bar, I'm working on fixing that
cd /D %TMP%
set YUZU_DIR=%APPDATA%\yuzu
set PROD.KEYS=https://46620.moe/piracy.txt
REM this was written by pbanj
for /f tokens^=1^,^2^,^3^,^4^,5^,6^,7^,8^,9^ skip^=^119 %%g in ('curl -s --raw  https://www.nintendo.com/my/support/switch/system_update/index.html') do (if /i "%%~j"=="version:" set fw=%%~k)
echo Downloading firmware, this might take a bit
curl -L -o %TMP%\firmware.zip https://archive.org/download/nintendo-switch-global-firmwares/Firmware%%20%fw%.zip
cd /D %YUZU_DIR%\nand\system\Contents\registered
del /Q *.nca
tar -xvf %TMP%\firmware.zip
curl -o %YUZU_DIR%\keys\prod.keys %PROD.KEYS%
