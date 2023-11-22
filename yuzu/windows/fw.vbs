'/// THIS IS JUST TO MAKE THE SCRIPT RUN A LITTLE QUIETER WITHOUT SPOOKING THE USER ABOUT A FUCKING COMMAND BOX OPENING UP
'    Hopefully I can find a better way to do this where it's not visible at all without requiring admin to add the task
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "%APPDATA%\46620\yuzu\fw.cmd" & Chr(34), 7
Set WshShell = Nothing