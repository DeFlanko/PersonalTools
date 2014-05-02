## Prerequisite Functions
function ListAdministrators($Group){
    $members= $Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $members
    }

function Ping-Server{
    Param([string]$srv)
    $pingresult = Get-WmiObject Win32_PingStatus -Filter "Address='$srv'"
    if($pingresult.StatusCode -eq 0) {$true} else {$false}
    }

## Get-LocalAdmins
function Get_LocalAdmin ($strComputer){
if (Ping-Server($strComputer))
    { 
    $computer = [ADSI]("WinNT://" + $strComputer + ",computer")
    $GroupName = "Administrators"
    $Group = $computer.psbase.children.find($Groupname)
    write-host -foregroundcolor green "====== $strComputer $Groupname List ====="
    ListAdministrators $Group
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
