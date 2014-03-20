'Written:   April 07, 2011
'Author:    Leith Ross
'Summary:   Reads the URLs on the Sheet defined in the input box from column also defind in input box and returns the IP address,
'           response time, and status in columns "B:D".
'           This works code with Windows XP and later.
'Version:   1


Sub GetIP()
On Error Resume Next
  Dim Cell As Range
  Dim colPings As Object, objPing As Object, strQuery As String
  Dim Rng As Range
  Dim RngEnd As Range
  Dim Wks As Worksheet
  Dim SRange As String
  Dim SSheet As String
  
  'What sheet?
  SSheet = InputBox("Set the Working Sheet", "Sheet", "Sheet")
  'MsgBox (pause)
  
  'What range of cells?
  SRange = InputBox("Set of Host Names Range", "Range", "A1:A10")
  'MsgBox (pause)
  
    Set Wks = Worksheets(SSheet)
    Set Rng = Wks.Range(SRange)
    
    Set RngEnd = Wks.Cells(Rows.Count, Rng.Column).End(xlUp)
    If RngEnd.Row < Rng.Row Then Exit Sub Else Set Rng = Wks.Range(Rng, RngEnd)
    
    For Each Cell In Rng
    
      'Define the WMI query
       strQuery = "SELECT * FROM Win32_PingStatus WHERE Address = '" & Cell & "'"

      'Run the WMI query
       Set colPings = GetObject("winmgmts://./root/cimv2").ExecQuery(strQuery)

      'Translate the query results to either True or False
       For Each objPing In colPings
         If Not objPing Is Nothing Then
            Cell.Offset(0, 1) = objPing.ProtocolAddress
            
            End If
       Next objPing
     
     Next Cell
    
End Sub

