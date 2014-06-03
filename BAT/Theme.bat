@ --------- To bypass any GPO for theme changing ---------------
@ First create your default.theme and place it in 
@ %LOCALAPPDATA%\Microsoft\Windows\Themes\Default\Default.theme
@ Save this file in C:\Scripts\
@ next create a Task in Task scheduler on login, to run the bat. 
@ --------------------------------------------------------------
@ ECHO OFF
rundll32.exe %SystemRoot%\system32\shell32.dll,Control_RunDLL %SystemRoot%\system32\desk.cpl desk,@Themes /Action:OpenTheme /file:"%LOCALAPPDATA%\Microsoft\Windows\Themes\Default\Default.theme" 
Exit
