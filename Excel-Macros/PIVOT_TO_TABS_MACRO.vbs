' Besure to convert your Pivot Tbale to CLASSIC first.

Sub PIVOT_2_TABS()
    Dim lCol As Long
    Dim c As Range
    Dim sField As String
    sField = "<ROW_NAME>"
    
    With ActiveSheet.PivotTables(1)
        With .RowRange
            On Error Resume Next
            lCol = WorksheetFunction.Match(sField, .Resize(1), 0)
            On Error GoTo 0
            If lCol = 0 Then
                MsgBox "Rowfield Header: " & sField & "not found."
                Exit Sub
            End If
            lCol = .Column + lCol - 1
        End With
        For Each c In .DataBodyRange.Resize(, 1)
           c.ShowDetail = True
           ActiveSheet.Name = .Parent.Cells(c.Row, lCol)
        Next c
    End With
End Sub
