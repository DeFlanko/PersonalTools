' This is an excel VBA and should be used for ALT+F11 Macros. The below is setup for a Button. 
Sub CreateNewWBS_Click()
' On Error Resume Next is to catch Worksheet filenames longer than 31 characters, and will still create the new file and move to the next one. 
On Error Resume Next
Dim wbThis As Workbook
Dim wbNew As Workbook
Dim ws As Worksheet
Dim strFilename As String
    ' Select your file and creates new files from worksheet names of the file selected.
    Set wbThis = Workbooks.Open(Application.GetOpenFilename())
    For Each ws In wbThis.Worksheets
        ' Just saves file as teh worksheet name  
        strFileName = wbThis.Path & "/" & ws.Name
        ' Saves file with Worksheet name and This Month and Year in file name
        'strFilename = wbThis.Path & "/" & ws.Name & MonthName(Month(Now()), True) & Year(Now())
        ' Saves file with Worksheet name and Manually entered Month and THIS Year in file name
        'strFilename = wbThis.Path & "/" & ws.Name & "MAR" & Year(Now())
        strFilename = wbThis.Path & "/" & ws.Name & "_CUSTOM_NAME_HERE.xlsx"
        ws.Copy
        Set wbNew = ActiveWorkbook
        ' Uncomment for worksheet renaming in the new file. Same Logic as the file name saving. 
        ' ActiveSheet.Name = ws.Name & MonthName(Month(Now()), True) & Year(Now())
        wbNew.SaveAs strFilename
        wbNew.Close
    Next ws
End Sub
