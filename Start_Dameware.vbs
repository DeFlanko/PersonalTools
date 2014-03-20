On error resume next
strComputer = (InputBox(" Computer name ", "Computer Name"))
strName = "dwmrcs" 
Set Services = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2").ExecQuery("select * from Win32_Service where Name = '" & strName & "'")
	For each Service in Services
		Set objShell = CreateObject("WScript.Shell")
		ObjShell.run("sc " & "\\" & strComputer & " config " & strName & " start= delayed-auto")
		REM msgbox("sc " & "\\" & strComputer & " config " & strName & " start= delayed-auto")
		ObjShell.run("sc "& "\\" & strComputer & " start " & strName)
		REM msgbox("sc "& "\\" & strComputer & " start " & strName)
		MsgBox(strComputer & chr(32) & strName & chr(32) & "Is ready for Remoting in!")
Next
