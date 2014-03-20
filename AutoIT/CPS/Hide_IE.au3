; Origional works of code from: http://www.autoitscript.com/forum/topic/132895-close-ie-on-seperate-login-box-button-click-help/
; Modified by James DiBernardo, and Shiddhalingesh Pattanashetter
; AutoIT guidance from Erik Nelson
; Writen for Molina Healthcare, Inc.
Opt("TrayIconHide", 1); Hide the System Tray Icon
$val = Run("C:\Program Files (x86)\Internet Explorer\Iexplore.exe http://JBOSSSERVER:9080/centricityps/cps/","C:\Program Files (x86)\Internet Explorer",@SW_SHOWMINIMIZED); Open the IE window Minimized
Sleep(3000); Wait 3 Seconds
$handle = WinGetHandle("http://JBOSSSERVER:9080/centricityps/cps/ - Windows Internet Explorer"); Capture the IE Window's handle
;MsgBox(4096, "Handle is", $handle)
$pid = ControlHide("http://JBOSSSERVER:9080/centricityps/cps/ - Windows Internet Explorer","",$handle); Hide the IE Window based on Handle ID
WinWait("[CLASS:CentricityLogonDlg]"); Centricity Login Box opening up
WinWaitClose("[CLASS:CentricityLogonDlg]"); Wait for the Login Window To close. 
Sleep (20000); Wait...
WinKill($handle); Close IE Window based on handle ID
WinWaitClose("Centricity Practice Solution");Wait for CPOPM06.exe to NOT Exist
