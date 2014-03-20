'Written:   March 6th, 2013
'Author:    James DiBernardo (with parts of code used form Leith Ross)
'Summary:   Reads the Hostname on the Sheet defined in the input box from column also defined
'           in input box and returns the MAC address.
'Version:   1


Sub GetMac()
On Error Resume Next
    Dim Cell As Range
    Dim colItems As Object, objItems As Object, strQuery As String
    Dim Rng As Range
    Dim RngEnd As Range
    Dim Wks As Worksheet
    Dim SRange As String
    Dim SSheet As String

'What sheet?
    SSheet = InputBox("Set the Working Sheet", "Sheet", "Sheet")
'MsgBox (pause)
  
'What range of cells?
    SRange = InputBox("Set of Host Names Range", "Range", "A2:A10")
'MsgBox (pause)
  
    Set Wks = Worksheets(SSheet)
    Set Rng = Wks.Range(SRange)
    
    Set RngEnd = Wks.Cells(Rows.Count, Rng.Column).End(xlUp)
    If RngEnd.Row < Rng.Row Then Exit Sub Else Set Rng = Wks.Range(Rng, RngEnd)
    
    For Each Cell In Rng
        
    'MsgBox Cell
    
        Set objWMIService = GetObject("winmgmts:\\" & Cell & "\root\cimv2")
        Set colItems = objWMIService.ExecQuery _
        ("Select * From Win32_NetworkAdapterConfiguration Where IPEnabled = True")
        For Each objItem In colItems
        If Not objItem Is Nothing Then
        Cell.Offset(0, 3) = objItem.MACAddress
        End If
        
        Next objItem
    Next Cell
    
End Sub


