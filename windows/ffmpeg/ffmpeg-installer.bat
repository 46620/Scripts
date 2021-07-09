:: This script is to be used along side the ffmpeg-aio.bat script as it will call it when it is done running.
:: If you downloadaed this on it's own, remove the call to ffmpeg-aio.bat at the end
:: Stackoverflow post 14639743 helped

@echo off

 call :isAdmin

 if %errorlevel% == 0 (
    goto :run
 ) else (
    echo Requesting administrative privileges...
    goto :UACPrompt
 )

 exit /b

 :isAdmin
    fsutil dirty query %systemdrive% >nul
 exit /b

 :run
  <YOUR BATCH SCRIPT HERE>
 exit /b

 :UACPrompt
   echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
   echo UAC.ShellExecute "cmd.exe", "/c %~s0 %~1", "", "runas", 1 >> "%temp%\getadmin.vbs"

   "%temp%\getadmin.vbs"
   del "%temp%\getadmin.vbs"
  exit /B`

cd /D %SystemRoot%\system32
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://dl.46620.moe/script-deps/ffmpeg/ffmpeg.exe', 'ffmpeg.exe')"
cmd ffmpeg-aio.bat
exit