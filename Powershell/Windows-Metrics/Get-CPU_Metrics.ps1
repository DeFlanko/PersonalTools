<#
.Synopsis
    To get an output of active running processes on remote servers in order of highest to lowest CPU %

.Syntax
    Run the PS1 and paste the Server FQDN in the inputbox

.Inputs
    Paste the FQDN of the server in the inputbox.

.Outputs
    Start Time
    20:06:29 04-25-2014
    ============== Localhost CLI Task Manager ==============

    Name                         CPU%   PID UserID                    
    ----                         ----   --- ------                    
    AeXNSAgent.exe                 55  2300 NT AUTHORITY\SYSTEM       
    SearchIndexer.exe              30  5824 NT AUTHORITY\SYSTEM       
    SearchProtocolHost.exe         18 12924 NT AUTHORITY\SYSTEM       
    SearchFilterHost.exe           12  4688 NT AUTHORITY\SYSTEM       
    WmiPrvSE.exe                    6 11516 NT AUTHORITY\LOCAL SERVICE
    System Idle Process    {100, 100}     0 \                         


    ===========================================================
    End Time
    20:07:25 04-25-2014
    Time Spent: 00:00:56.2970000

.Notes
    Author:       James DiBernardo
    Name:         Get-CPU-Metrics.ps1
    Version:      1.0.0
    DateCreated:  04252014
    DateModified: -

.Examples
    n/a
    
#>
# To Suppress the Red Errors to make Output Cleaner looking \\ Remove if you need to see errors. 
$ErrorActionPreference = "SilentlyContinue"
# $ErrorActionPreference = "Continue"

function Get_CPU ($strComputer){
# Add in a Time Stamp
$strStartTime = Get-Date
$strStartTime | Out-Null
Write-Host "Start Time"
(get-date).toString(‘HH:mm:ss MM-dd-yyyy’)
Write-Host -ForegroundColor Green "============== $StrComputer CLI Task Manager =============="
$Taskman = Get-WmiObject Win32_Process -ComputerName $StrComputer
foreach ($p in $Taskman){
    $p | Add-Member -Type NoteProperty -Name Process -Value ($p.Name)
    $p | Add-Member -Type NoteProperty -Name UserID -Value ($p.GetOwner().Domain + "\" + $p.GetOwner().User)
    $p | Add-Member -Type NoteProperty -Name CPU% -Value (Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | Where-Object{$_.IDProcess -eq $p.ProcessID}).PercentProcessorTime
    $p | Add-Member -Type NoteProperty -Name PID -Value ($p.ProcessID)
    }
$Taskman | Sort-Object CPU% -Descending | Where-Object CPU% -GT "0"| Format-Table Name, CPU%, PID, UserID -AutoSize 
Write-Host -ForegroundColor Green "==========================================================="
# Add in a Time Stamp
$strEndTime = Get-Date
$strEndTime | Out-Null
Write-Host "End Time"
(get-date).toString(‘HH:mm:ss MM-dd-yyyy’)
Write-Host -ForegroundColor Yellow "Time Spent: $($strEndTime - $strStartTime)"
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
        Get_Cpu -strComputer $Item
    }
    Else
    {
        Write-Host -ForegroundColor Red "Cannot Connect to $Item"
    }
}
