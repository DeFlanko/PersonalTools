# Prerequisite Functions\
function ListMembers($Group){
    $members= $Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $members
}
function Ping-Server {
    Param([string]$srv)
    $pingresult = Get-WmiObject Win32_PingStatus -Filter "Address='$srv'"
    if($pingresult.StatusCode -eq 0) {$true} else {$false}
}
Function SelectDomain{
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select a Domain"
$objForm.Size = New-Object System.Drawing.Size(300,250) 
$objForm.StartPosition = "CenterScreen"

# Got rid of the block of code related to KeyPreview and KeyDown events.

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,180)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"

# Got rid of the Click event for the OK button, and instead just assigned its DialogResult property to OK.
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK

$objForm.Controls.Add($OKButton)

# Setting the form's AcceptButton property causes it to automatically intercept the Enter keystroke and
# treat it as clicking the OK button (without having to write your own KeyDown events).
$objForm.AcceptButton = $OKButton

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,180)
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
$objLabel.Text = "Please select a Domain where the User/Group Lives:"
$objForm.Controls.Add($objLabel) 

$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,40) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 140

###################### DEFINE YOUR DOMAINS HERE!!!

[void] $objListBox.Items.Add("molina.mhc")
[void] $objListBox.Items.Add("wvmmis.local")
[void] $objListBox.Items.Add("Core.him")
[void] $objListBox.Items.Add("Dev.Core.him")
[void] $objListBox.Items.Add("FLPrims.Core.him")
[void] $objListBox.Items.Add("ID.Core.him")
[void] $objListBox.Items.Add("LABTR.Core.him")
[void] $objListBox.Items.Add("ME.Core.him")
[void] $objListBox.Items.Add("NJ.Core.him")
[void] $objListBox.Items.Add("WV.Core.him")

$objForm.Controls.Add($objListBox) 

$objForm.Topmost = $True

# Now, instead of having events in the form assign a value to a variable outside of their scope, the code that calls the dialog
# instead checks to see if the user pressed OK and selected something from the box, then grabs that value.

$result = $objForm.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $objListBox.SelectedIndex -ge 0)
{
    $SelectedDomain = $objListBox.SelectedItem
    # Do something with $SelectedDomain
    $SelectedDomain
}
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
$objLabel.Text = "Please select a group:"
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

#Add-User_To_Group
function Add_To_Group ($strComputer){ 
if (Ping-Server($strComputer)) { 
    $computer = [ADSI]("WinNT://" + $strComputer + ",computer")
    $DomainName =[string](SelectDomain)
    $GroupName = [string](SelectGroup)
    $Group = $computer.psbase.children.find($Groupname)
# This will list what’s currently in Administrator Group so you can verify the result
    write-host -foregroundcolor green "====== $strComputer $Groupname BEFORE ====="
    ListMembers $Group
    write-host -foregroundcolor green "====== BEFORE ====="
# Even though we are adding the AD account
# It is being added to the local computer and so we will need to use WinNT: provider
    $Group.add("WinNT://" + $DomainName + "/" + $ItemUser) 
    write-host -foregroundcolor green "====== $strComputer $Groupname AFTER ====="
    ListMembers $Group
    write-host -foregroundcolor green "====== AFTER ====="
    }
else
    {
        Write-Host -foregroundcolor red "$strComputer is not pingable"
    }
}

## Lets Build an InputBox
function GetInputUser ($DefaultText = "",$LabelMessage = "Please enter the information in the space below:",$MultiLine = $true)
{
    $objForm = New-Object System.Windows.Forms.Form 
    $objForm.Text = "User to Remove Input Box"
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

function GetInputServer ($DefaultText = "",$LabelMessage = "Please enter the information in the space below:",$MultiLine = $true)
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

$ItemUser = GetInputUser -LabelMessage "Input a User/Security group to Add:" -MultiLine $false
$ItemList = GetInputServer -LabelMessage "Input FQDN of Servers to Process:" -MultiLine $true

$ItemList = $ItemList.Split()

foreach ($Item in $ItemList)
{
    if (Test-Connection $Item -Count 1) 
    {
        Add_To_Group -strComputer $Item 
    }
    Else
    {
        Write-Host -ForegroundColor Red "Cannot Connect to $Item"
    }
} 
