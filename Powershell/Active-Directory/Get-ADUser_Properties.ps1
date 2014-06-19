#Do Things
function Get_User_Properties ($strUser){
    #the results Array
    $Results =@()

    #constants for the variables.
    $filter = "Name -Like ""*$strUser*"""
    
    #variables for the Spreadsheet
    $Name = Get-ADUser -Filter $filter -Properties * | % {$_.Name}
    $SamName = Get-ADUser -Filter $filter -Properties *| % {$_.SamAccountName}
    $Email = Get-ADUser -Filter $filter -Properties *| % {$_.EmailAddress}
    $Office = Get-ADUser -Filter $filter -Properties *| % {$_.Office}
    $Company = Get-ADUser -Filter $filter -Properties *| % {$_.Company}
    $State = Get-ADUser -Filter $filter -Properties *| % {$_.State}
    
    #Build the Spreadsheet
    $TempOBJ = New-Object PSObject
        $TempOBJ| Add-Member -MemberType NoteProperty -Name "Name" -Value $Name
        $TempOBJ| Add-Member -MemberType NoteProperty -Name "AD Name" -Value $SamName
        $TempOBJ| Add-Member -MemberType NoteProperty -Name "Email Address" -Value $Email
        $TempOBJ| Add-Member -MemberType NoteProperty -Name "Office" -Value $Office
        $TempOBJ| Add-Member -MemberType NoteProperty -Name "Company" -Value $Company
        $TempOBJ| Add-Member -MemberType NoteProperty -Name "State" -Value $State

    $Results += $TempOBJ
    $Results | Export-Csv -path ".\Export.csv" -Force -NoTypeInformation -Append
}


## Lets Build an InputBox

function GetInputMultiLine ($DefaultText = "",$LabelMessage = "Please enter the information in the space below:",$MultiLine = $true)
{
    $objForm = New-Object System.Windows.Forms.Form 
    $objForm.Text = "Server List Input Box"
    $objForm.Size = New-Object System.Drawing.Size(300,200) 
    $objForm.StartPosition = "CenterScreen"

    $objForm.KeyPreview = $True
    If(!$MultiLine)
        {
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") {$objForm.Close()}})
        }
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") {$objForm.Close()}})

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(75,125)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.Add_Click({$objForm.Close()})
    $objForm.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(150,125)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.Add_Click({$objForm.Close()})
    $objForm.Controls.Add($CancelButton)

    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,10) 
    $objLabel.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel.Text = $LabelMessage
    $objForm.Controls.Add($objLabel) 

    $objTextBox = New-Object System.Windows.Forms.TextBox 
    $objTextBox.Location = New-Object System.Drawing.Size(10,30) 
    $objTextBox.Size = New-Object System.Drawing.Size(260,85)
    If($MultiLine)
    {
        $objTextBox.multiline = $true
    }
    If($DefaultText.length -gt 0)
    {
        $objTextBox.Text = $DefaultText
    }

    $objForm.Controls.Add($objTextBox) 
    $objForm.Topmost = $True
    $objForm.Add_Shown({$objForm.Activate()})
    [void] $objForm.ShowDialog()

    $objTextBox.Text
} 

$ItemList = GetInputMultiLine -LabelMessage "Input List of Users to Get Properties of:" -MultiLine $true
$ItemList = $ItemList.Split("`r`n")

foreach ($Item in $ItemList){
    If($Item){
        Get_User_Properties -strUser $Item
        }
    }
Import-CSV -Path ".\Export.csv" | Format-Table -Autosize
