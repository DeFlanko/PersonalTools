## Prerequisite Functions
Function ListMembers($Group){
    $members= $Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $members
    }

Function Ping-Server{
    Param([string]$srv)
    $pingresult = Get-WmiObject Win32_PingStatus -Filter "Address='$srv'"
    if($pingresult.StatusCode -eq 0) {$true} else {$false}
    }

Function SelectGroup{
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select a Group"
$objForm.Size = New-Object System.Drawing.Size(300,200) 
$objForm.StartPosition = "CenterScreen"

# Got rid of the block of code related to KeyPreview and KeyDown events.

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"

# Got rid of the Click event for the OK button, and instead just assigned its DialogResult property to OK.
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK

$objForm.Controls.Add($OKButton)

# Setting the form's AcceptButton property causes it to automatically intercept the Enter keystroke and
# treat it as clicking the OK button (without having to write your own KeyDown events).
$objForm.AcceptButton = $OKButton

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"

# Got rid of the Click event for the Cancel button, and instead just assigned its DialogResult property to Cancel.
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

$objForm.Controls.Add($CancelButton)

# Setting the form's CancelButton property causes it to automatically intercept the Escape keystroke and
# treat it as clicking the OK button (without having to write your own KeyDown events).
$objForm.CancelButton = $CancelButton

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please select a Group:"
$objForm.Controls.Add($objLabel) 

$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 80

[void] $objListBox.Items.Add("Administrators")
[void] $objListBox.Items.Add("Remote Desktop Users")
[void] $objListBox.Items.Add("Power Users")
[void] $objListBox.Items.Add("User")

$objForm.Controls.Add($objListBox) 

$objForm.Topmost = $True

# Now, instead of having events in the form assign a value to a variable outside of their scope, the code that calls the dialog
# instead checks to see if the user pressed OK and selected something from the box, then grabs that value.

$result = $objForm.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $objListBox.SelectedIndex -ge 0)
{
    $SelectedGroup = $objListBox.SelectedItem
    # Do something with $SelectedGroup
    $SelectedGroup
}
}



## Get-UsersOfGroup
function Get_LocalAdmin ($strComputer){
if (Ping-Server($strComputer))
    { 
    $computer = [ADSI]("WinNT://" + $strComputer + ",computer")
    $GroupName = [string](SelectGroup)
    $Group = $computer.psbase.children.find($Groupname)
    write-host -foregroundcolor green "====== $strComputer $Groupname List ====="
    ListMembers $Group
    write-host -foregroundcolor green "====== END ====="
    }
else
   {
   write-host -foregroundcolor red "$strComputer is not pingable"
   }
}

## Lets Build an InputBox
function GetInput ($DefaultText = "",$LabelMessage = "Please enter the information in the space below:",$MultiLine = $true)
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
        #$objTextBox.ScrollBars = $True
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

$ItemList = GetInput -LabelMessage "Input FQDN of Servers to Process:" -MultiLine $true
$ItemList = $ItemList.Split()

foreach ($Item in $ItemList)
{
    if (Test-Connection $Item -Count 1) 
    {
        Get_LocalAdmin -strComputer $Item
    }
    Else
    {
        Write-Host -ForegroundColor Red "Cannot Connect to $Item"
    }
} 
