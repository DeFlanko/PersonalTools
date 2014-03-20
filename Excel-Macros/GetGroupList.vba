' Title:        Security Group LDAP query to list Users.
' Description:  Group Name (Security group), Employee Number, Display Name, Login Name, Department
' Source:       Unknown
' Modified By:  James DiBernardo
' Version:      1

Option Explicit
Sub GetGroupData()
    GetGroupList Sheet1.Range("A1").Value, Sheet1.Range("A1")
End Sub

Sub GetGroupList(strGroup As String, rngOut As Range)
    Dim objConnection, objCommand, objRecordSet, objGroup, objRootDSE, objMember
    Dim varGroups, varItem
    Dim strLine
    Dim wksOut As Worksheet
    rngOut.CurrentRegion.Offset(1).ClearContents
    Dim SecurityGrpInput As String
    Set wksOut = ActiveSheet
    SecurityGrpInput = InputBox("Enter in Security Group", "AD Secuirty Group")
    With wksOut
        ' add titles
        .Range("A1:E1").Font.Bold = True
        .Range("A1:E1").Font.Color = RGB(255, 255, 255)
        .Range("A1:E1").Interior.Color = RGB(0, 0, 0)
        .Range("A1").Value = "Group Name"
        .Range("B1").Value = "Employee Number"
        .Range("C1").Value = "Display Name"
        .Range("D1").Value = "Login Name"
        .Range("E1").Value = "Department"
        ' first output cell
        Set rngOut = .Range("A2")
    End With
    ' Search
    varGroups = Array(SecurityGrpInput)
    On Error GoTo ErrorHandler
          For Each varItem In varGroups
        ' output group name
        With rngOut
            .Value = varItem
            .Font.Bold = True
        End With
    Set objConnection = CreateObject("ADODB.Connection")
    objConnection.Provider = "ADsDSOObject"
    objConnection.Open "Active Directory Provider"
    Set objCommand = CreateObject("ADODB.Command")
    objCommand.ActiveConnection = objConnection
    Set objRootDSE = GetObject("LDAP://rootDse")
    objCommand.CommandText = "SELECT aDSPath FROM 'LDAP://" & objRootDSE.Get("defaultNamingContext") & _
    "' WHERE objectClass='group' And name = '" & LTrim(RTrim(varItem)) & "' order by name,department"
    Set objRootDSE = Nothing
    objCommand.Properties("Page Size") = 1000
    objCommand.Properties("Timeout") = 0
    objCommand.Properties("Cache Results") = False
    Set objRecordSet = objCommand.Execute
    
    While Not objRecordSet.EOF
        Set objGroup = GetObject(objRecordSet.Fields("aDSPath"))
         
        For Each objMember In objGroup.Members
        On Error Resume Next
        'Add rows here, AD Field names can be found here: http://fsuid.fsu.edu/admin/lib/WinADLDAPAttributes.html
            'rngOut.Offset(, 1).Value = objMember.Get("wWWHomePage") 'whats "shown" in AD for Employee Number
            rngOut.Offset(, 1).Value = objMember.Get("employeeid") 'whats behind the sceens in AD for Employee Number
            rngOut.Offset(, 2).Value = objMember.Get("displayName")
            rngOut.Offset(, 3).Value = objMember.Get("samaccountname")
            rngOut.Offset(, 4).Value = objMember.Get("department")
        Set rngOut = rngOut.Offset(1)
        'End If
        Next
        Set objGroup = Nothing
        objRecordSet.MoveNext
    Wend
    objConnection.Close
    Set objRecordSet = Nothing
    Set objCommand = Nothing
    Set objConnection = Nothing
        Next varItem
End
ErrorHandler:
objConnection.Close
   Set objRecordSet = Nothing
   Set objCommand = Nothing
   Set objConnection = Nothing
   MsgBox "Security Group cannot be blank, please press the Run Button to try again"
End Sub
