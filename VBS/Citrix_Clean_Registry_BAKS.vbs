runAsCscript()

'If it finds a temporary profile, should it delete it? If it is false, you will get a list printed to the screen.
deleteKey = TRUE



Dim arrComputers
'If you want to run this script on the local computer arrComputers should just contain a period: arrComputers = Array(".")
  
'This is a list of computers we want to check for temporary profiles. 
arrComputers = Array(".")



const HKEY_LOCAL_MACHINE = &H80000002

For Each strComputer in arrComputers
 findBakProfiles(strComputer)

Next


Function findBakProfiles(strComputer)
 Set objReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
 strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
 objReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys
 
 For Each subkey In arrSubKeys
    'wscript.echo subkey
	
	
	Set objRegEx = CreateObject("VBScript.RegExp")
	objRegEx.Pattern = ".*\.bak$"
	Set regMatches = objRegEx.Execute(subkey)
	
			If regMatches.Count > 0 Then
        		For Each strMatch in regMatches 
						strBadKey = strKeyPath & "\" & strMatch
						objReg.GetExpandedStringValue HKEY_LOCAL_MACHINE, strBadKey, "ProfileImagePath", strValue
            			wscript.echo "Server Name: " & strComputer 
						wscript.echo "Registry Key: " & strMatch  
						wscript.echo "Directory: " & strValue
							
						if deleteKey Then
							objReg.CheckAccess HKEY_LOCAL_MACHINE, strBadKey, DELETE, bHasAccessRight
							If bHasAccessRight = True Then
								wscript.echo "We have Delete Access Rights on Key"
							Else
								wscript.echo "We Do Not Have Delete Access Rights on Key"
							End If
							'wscript.echo strBadKey
							'You cant delete a key if it has any sub keys. This code only works to one level right now. 
							objReg.EnumKey HKEY_LOCAL_MACHINE, strBadKey, arrKeyNames
 
							
							If isArray(arrKeyNames) Then							
								For Each strKey in arrKeyNames
									'delete all of the sub keys
									wscript.echo "Removing Key: " & strKey
									strBadSubKey = strBadKey & "\" & strKey
									objReg.DeleteKey HKEY_LOCAL_MACHINE, strBadSubKey
								Next
							End If
							
							
							objReg.DeleteKey HKEY_LOCAL_MACHINE, strBadKey
							wscript.echo "Removing Profile: " & strBadKey
							
						
						End If
        		Next
    		End If
	
	
 Next
End Function

'just a little trick to make sure that the application waits until we press enter to close

wscript.echo "DONE, Press Enter to continue"
WScript.StdIn.ReadLine 

Function runAsCscript()

    Dim Arg, Str 
    If Not LCase( Right( WScript.FullName, 12 ) ) = "\cscript.exe" Then 
        For Each Arg In WScript.Arguments 
            If InStr( Arg, " " ) Then Arg = """" & Arg & """" 
            Str = Str & " " & Arg 
        Next 
        CreateObject( "WScript.Shell" ).Run "cscript.exe //nologo """ & WScript.ScriptFullName & """" & Str 
        WScript.Quit 
    End If 

End Function
