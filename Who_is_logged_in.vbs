Option Explicit 
Dim strComputerName 
Dim objWMIServices 
Dim objUserSet 
Dim oWshShell 
Dim User 
Dim colOperatingSystems 
Dim objOperatingSystem 
On Error Resume Next 
Set oWshShell = CreateObject("Wscript.Shell") 
'************************************************************************************************ 
'* Get user input for computer name. If nothing is entered, this will default to the local system 
'************************************************************************************************ 
strComputerName = InputBox ("Enter the name of the computer you wish to query","Target system", ".") 
'*  Configure WMI connection properties for target system 
objWMIServices = "winmgmts:{impersonationLevel=impersonate}!//"& strComputerName &"" 
'**************************************************************************************************** 
'* Connect to WMI and get Computer system properties 
'* If connection is not successful, either prompt for alternate credentials or display error and exit 
'**************************************************************************************************** 
Set objUserSet = GetObject( objWMIServices ).InstancesOf ("Win32_ComputerSystem") 
If Err.number <> 0 Then 
If Err.Number = "-2147217405" Then 
btnCode = oWshShell.Popup ("Access Denied" & Chr(13) & "Try again with alternate credentials?" , 30, strComputerName, 4+32) 

Select Case BtnCode 
   case 6       altCreds() 
   case 7       oWshShell.Popup "Process has been cancelled by user",5,"Notice...",16 
    wScript.Quit 
   case -1     oWshShell.Popup "No user input. Process has been aborted.",10,"Notice...",64 
    wScript.Quit   
End Select 

ElseIf Err.Number = "462" Then 
oWshShell.Popup "Host Unreachable", 10, strComputerName, 48 
Else 
oWshShell.Popup "Attempt to query current user on: " & strComputerName & " has failed." & Chr(13) & Err.Number & " : " & Err.Description, 10, strComputerName, 48 
End If 
Err.Clear 
wScript.Quit 
Else 
Set colOperatingSystems = GetObject( objWMIServices ).InstancesOf ("Win32_OperatingSystem") 

If Err.Number <> 0 Then WScript.Echo Err.Number & " : " & Err.Description 
Err. Clear 
End If 
'******************************** 
'* Look for user name in data set 
'******************************** 
for each User in objUserSet 
If User.UserName <> "" Then 
   oWshShell.Popup "The current user on " & strComputerName & " is: " & User.UserName & Chr(13) & upTime(strComputerName), 10, strComputerName, 64 
Else 
   oWshShell.Popup "There are no users currently logged in at " & strComputerName & Chr(13) & upTime(strComputerName), 10, strComputerName, 64 
End If 
Next 
'* End of script processing 
'************************** 

'******************************************************************************** 
'* Function upTime() retrieves last boot time from system and calculates uptime 
'*      
'* Sets function value to string declaring uptime in Hours, Minutes & seconds 
'******************************************************************************** 
Function upTime(strComputer) 
Dim objOS 
Dim dtmBootup 
Dim dtmLastBootupTime 
Dim dtmSystemUptime 
On error Resume Next 
upTime = 0 
For Each objOS in colOperatingSystems 
  dtmBootup = objOS.LastBootUpTime 
  dtmLastBootupTime = WMIDateStringToDate(dtmBootup) 
  dtmSystemUptime = "Last system reboot occurred " & DateDiff("h", dtmLastBootUpTime, Now) & " hours, " & Int(DateDiff("n", dtmLastBootUpTime, Now)/60) & " minutes, " & DateDiff("n", dtmLastBootUpTime, Now) Mod 60 & " seconds ago."  
If Err.Number =0 Then 
upTime = dtmSystemUptime 
Else 
upTime = "Last reboot time cannot be retrieved from " & strComputer 
End If 
Err.Clear 
Next 
End Function 
Function WMIDateStringToDate(dtmBootup) 
  WMIDateStringToDate = CDate(Mid(dtmBootup, 5, 2) & "/" & _ 
       Mid(dtmBootup, 7, 2) & "/" & Left(dtmBootup, 4) _ 
       & " " & Mid (dtmBootup, 9, 2) & ":" & _ 
       Mid(dtmBootup, 11, 2) & ":" & Mid(dtmBootup, _ 
       13, 2)) 
End Function 

'******************************************************************************** 
'* Function altCreds() Prompts user ot enter name and password for use in 
'*        establishing WMI connection if current credentials fail 
'******************************************************************************** 
Function altCreds(sHost) 
Dim sUser 
Dim sPass 
Dim oSWbemLocator 
Dim oSWbemServices 

sUser = InputBox("Please enter the Administrator Name: ") 
sPass = InputBox("Please enter the administrator password: ") 
On Error Resume Next 
Set oSWbemLocator = CreateObject("WbemScripting.SWbemLocator") 
Set oSWbemServices = oSWbemLocator.ConnectServer _ 
  (sHost, "root\cimv2", sUser, sPass) 

If Err.Number <> 0 Then 
oWshShell.Popup "WMI Connection was not successful. "  & Chr(13) & Err.Description, 10, Err.Source & " on " & sHost, 48 
Else 
Set objUserSet = oSWbemServices.ExecQuery ("Select * from Win32_ComputerSystem") 
Set colOperatingSystems = oSWbemServices.ExecQuery ("Select * from Win32_OperatingSystem") 

End If 
End Function 
