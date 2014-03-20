'Written:           November 07, 2010
'Updated:           11/8/2013
'Author:            Leith Ross
'Summary:           Returns the information for each account on the local computer.
'Update Notes:      Input box technique; still a WIP - Currently not functional!
'Version:           1.1

Sub GetAccountsInfo()
  
  Dim colItems As Object
  Dim Msg As String
  Dim objWMIService As Object
  Dim R As Long
  Dim Rng As Range
  Dim strComputer As String
  Dim Wks As Worksheet
    
    'What sheet?
    SSheet = InputBox("Set the Working Sheet", "Sheet", "Sheet")
  
    'What range of cells?
    SRange = InputBox("Set of Host Names Range", "Range", "A2:A10")
  
    Set Wks = Worksheets(SSheet)
    Set Rng = Wks.Range(SRange)
    
    strComputer = "."
    Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
    Set colItems = objWMIService.ExecQuery("Select * from Win32_UserAccount", , 48)
    
      For Each objItem In colItems
        If Not objItem Is Nothing Then
          Msg = Msg & "AccountType: " & objItem.AccountType & vbCrLf
          Msg = Msg & "Caption: " & objItem.Caption & vbCrLf
          Msg = Msg & "Description: " & objItem.Description & vbCrLf
          Msg = Msg & "Disabled: " & objItem.Disabled & vbCrLf
          Msg = Msg & "Domain: " & objItem.Domain & vbCrLf
          Msg = Msg & "FullName: " & objItem.FullName & vbCrLf
          Msg = Msg & "InstallDate: " & objItem.InstallDate & vbCrLf
          Msg = Msg & "Lockout: " & objItem.Lockout & vbCrLf
          Msg = Msg & "Name: " & objItem.Name & vbCrLf
          Msg = Msg & "PasswordChangeable: " & objItem.PasswordChangeable & vbCrLf
          Msg = Msg & "PasswordExpires: " & objItem.PasswordExpires & vbCrLf
          Msg = Msg & "PasswordRequired: " & objItem.PasswordRequired & vbCrLf
          Msg = Msg & "SID: " & objItem.SID & vbCrLf
          Msg = Msg & "SIDType: " & objItem.SIDType & vbCrLf
          Msg = Msg & "Status: " & objItem.Status & vbCrLf
          'Rng.Offset(0, R).Resize(15, 1).Value = WorksheetFunction.Transpose(Split(Msg, vbCrLf))
          Rng.Offset(R, 0).Resize(15, 1).Value = WorksheetFunction.Transpose(Split(Msg, vbCrLf))
          R = R + 16
          Msg = ""
        End If
      Next
    
End Sub
