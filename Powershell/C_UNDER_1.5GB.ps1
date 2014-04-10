<#
  .Synopsis
    Cleans the C Drive of Remote Servers

  .Syntax
    Run the PS1 and paste the Server FQDN in the inputbox

  .Description
    For each server listed in the inputbox it goes though and cleans up the tempoary files on those machines.

  .Parameters
    n/a

  .Inputs
    Paste the FQDN of the server in the inputbox.

  .Outputs
    PS C:\Windows\system32> \\MHCALBSYSADPV01\SysAdmins\Scripts\Powershell_Scripts\Clean_C_Drive\C_UNDER_1.5GB.ps1
    Start Time
    10:47:14 04-10-2014
    =======================================BEFORE CLEAN UP===========================================
    Localhost C: has 28.0 GB free of 119.2 GB Total
    =================================================================================================
    =================================================================================================
    Now Cleaning Folders in Localhost
    Access denied on \\Localhost\C$\Windows\ProPatches\Patches
    Now Copying DelProf_2k8 to Localhost
    Now Running DelProf_2k8 on Localhost
    Now Copying RemoveStaleVirusDefs.exe to Localhost
    Now Running RemoveStaleVirusDefs.exe on Localhost
    Now Cleaning Recyclebin on Localhost
    =================================================================================================
    ========================================AFTER CLEAN UP===========================================
    Localhost C: has 28.1 GB free of 119.2 GB Total
    =================================================================================================
    End Time
    10:47:17 04-10-2014
    Time Spent: 00:00:02.7640000

  .Notes
    Author:       James DiBernardo
    Name:         C_UNDER_1.5GB.ps1
    Version:      1.0.0
    DateCreated:  04012014
    DateModified: 04102014
    
  .Examples
    -------------------------- EXAMPLE 1 --------------------------

    PS C:\Windows\system32> \\MHCALBSYSADPV01\SysAdmins\Scripts\Powershell_Scripts\Clean_C_Drive\C_UNDER_1.5GB.ps1
    Start Time
    10:47:14 04-10-2014
    =======================================BEFORE CLEAN UP===========================================
    Localhost C: has 28.0 GB free of 119.2 GB Total
    =================================================================================================
    =================================================================================================
    Now Cleaning Folders in Localhost
    Access denied on \\Localhost\C$\Windows\ProPatches\Patches
    Now Copying DelProf_2k8 to Localhost
    Now Running DelProf_2k8 on Localhost
    Now Copying RemoveStaleVirusDefs.exe to Localhost
    Now Running RemoveStaleVirusDefs.exe on Localhost
    Now Cleaning Recyclebin on Localhost
    =================================================================================================
    ========================================AFTER CLEAN UP===========================================
    Localhost C: has 28.1 GB free of 119.2 GB Total
    =================================================================================================
    End Time
    10:47:17 04-10-2014
    Time Spent: 00:00:02.7640000

  .RelatedLinks
    \\MHCALBSYSADPV01\SysAdmins\Scripts\Powershell_Scripts\Clean_C_Drive\C_UNDER_1.5GB.ps1
    
#>
# To Suppress the Red Errors \\ Remove if you need to see errors. 
$ErrorActionPreference = "SilentlyContinue"
# $ErrorActionPreference = "Continue"

function RunCleanup ($strComputer)
{
# Add in a Time Stamp
$strStartTime = Get-Date
$strStartTime | Out-Null
Write-Host "Start Time"
(get-date).toString(‘HH:mm:ss MM-dd-yyyy’)

# Static Locations
    $strFileRepo = "mhcalbsysadpv01\SysAdmins\Scripts\Powershell_Scripts\Clean_C_Drive"

# Folders to Clean
    $strFolder_0_1 = "\\$strComputer\C$\Temp" # Per Ricky
    $strFolder_0_2 = "\\$strComputer\C$\Windows\Temp" # Per Ricky
    $strFolder_0_3 = "\\$strComputer\C$\Windows\SoftwareDistribution\Download" # Per Ricky
    $strFolder_0_4 = "\\$strComputer\C$\Windows\ProPatches\Patches" # Per Ricky
    #$strFolder_0_5 = "\\$strComputer\C$\`$Recycle.bin" # Per James	-- Defined using psexec
        
#Folders with files older than 7 days
    $strFolder_7_1 = "\\$strComputer\C$\ProgramData\Microsoft Visual Studio\10.0\TraceDebugging" # Per Phillip
    $strFolder_7_2 = "\\$strComputer\C$\inetpub\logs\LogFiles" # Per Ricky

#Folders with files older than 180 days
    $strFolder_180_1 = "\\$strComputer\C$\Program Files\Microsoft SQL Server\100\Setup Bootstrap\Update Cache" # Per Phillip    

#Folders with files older than 270 days
    $strFolder_270_1 = "\\$strComputer\C$\Windows\Installer" # Per Phillip

#Folders with files older than 365 days
    $strFolder_365_1 = "\\$strComputer\C$\PerfLogs" # Per James	

# determine how far back we go based on current date
    $curr_date = Get-Date
    $max_days_7 = "-7"
    $del_date_7 = $curr_date.AddDays($max_days_7)
    $max_days_180 = "-180"
    $del_date_180 = $curr_date.AddDays($max_days_180)    
    $max_days_270 = "-270"
    $del_date_270 = $curr_date.AddDays($max_days_270)
    $max_days_365 = "-365"
    $del_date_365 = $curr_date.AddDays($max_days_365)

# Calculate the Free Space on "C"
$size = ([wmi]"\\$strComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'").Size
$free = ([wmi]"\\$StrComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'").FreeSpace
$disk = ([wmi]"\\$strComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'")
Write-Host -foregroundcolor Green "=======================================BEFORE CLEAN UP==========================================="
"$strComputer C: has {0:#.0} GB free of {1:#.0} GB Total" -f ($disk.FreeSpace/1GB),($disk.Size/1GB) | Write-Output
Write-Host -foregroundcolor Green "================================================================================================="

<#
Write-Host -foregroundcolor Yellow "=======================================FILES TO BE CLEANED======================================="
Write-Host -foregroundcolor Yellow "Now Identifying Sizes of Folders in $strComputer"

# We identify the folders we want to Measure and their contents.

$colItems_0_1 = (Get-ChildItem $strFolder_0_1 -recurse | Measure-Object -property length -sum)
"$strFolder_0_1 is {0:N2}" -f ($colItems_0_1.sum / 1GB) + " GB"
$colItems_0_2 = (Get-ChildItem $strFolder_0_2 -recurse | Measure-Object -property length -sum)
"$strFolder_0_2 is {0:N2}" -f ($colItems_0_2.sum / 1GB) + " GB"
$colItems_0_3 = (Get-ChildItem $strFolder_0_3 -recurse | Measure-Object -property length -sum)
"$strFolder_0_3 is {0:N2}" -f ($colItems_0_3.sum / 1GB) + " GB"
$colItems_0_4 = (Get-ChildItem $strFolder_0_4 -recurse | Measure-Object -property length -sum)
"$strFolder_0_4 is {0:N2}" -f ($colItems_0_4.sum / 1GB) + " GB"
$colItems_7_1 = (Get-ChildItem $strFolder_7_1 -recurse | Measure-Object -property length -sum)
"$strFolder_7_1 is {0:N2}" -f ($colItems_7_1.sum / 1GB) + " GB"
$colItems_7_2 = (Get-ChildItem $strFolder_7_2 -recurse | Measure-Object -property length -sum )
"$strFolder_7_2 is {0:N2}" -f ($colItems_7_2.sum / 1GB) + " GB"
$colItems_180_1 = (Get-ChildItem $strFolder_180_1 -recurse | Measure-Object -property length -sum)
"$strFolder_180_1 is {0:N2}" -f ($colItems_180_1.sum / 1GB) + " GB"
$colItems_270_1 = (Get-ChildItem $strFolde_270_1 -recurse | Measure-Object -property length -sum)
"$strFolder_270_1 is {0:N2}" -f ($colItems_270_1.sum / 1GB) + " GB"
$colItems_365_1 = (Get-ChildItem $strFolder_365_1 -recurse | Measure-Object -property length -sum)
"$strFolder_365_1 is {0:N2}" -f ($colItems_365_1.sum / 1GB) + " GB"

#Now we sum up the totals -- This part is not shown // Also not too sure if its needed... 

$report = @(
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems_0_1.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems_0_2.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems_0_3.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems_0_4.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems_7_1.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems_7_2.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems_180_1.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems_270_1.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems_365_1.sum / 1GB) }
    )

# process: group by 'Item' then sum 'Average' for each group and create the Summed Output in GB

$report | Group-Object Item | %{
     New-Object psobject -Property @{
        Item = $_.Name
        Sum = ($_.Group | Measure-Object Average -Sum).Sum
     }
}

Write-Host -foregroundcolor Yellow "Files to be removed on $strComputer"
# Identifying the Files to be deleted by using the "-WhatIf"
Remove-Item $strFolder_0_1\* -Recurse -Force -WhatIf
Remove-Item $strFolder_0_2\* -Recurse -Force -WhatIf
Remove-Item $strFolder_0_3\* -Recurse -Force -WhatIf
Remove-Item $strFolder_0_4\* -Recurse -Force -WhatIf
Get-ChildItem $strFolder_7_2 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_7 } | Remove-Item -Recurse -Force -WhatIf
Get-ChildItem $strFolder_7_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_7 } | Remove-Item -Recurse -Force -WhatIf
Get-ChildItem $strFolder_270_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_270 } | Remove-Item -Recurse -Force -WhatIf
Get-ChildItem $strFolder_365_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_365 } | Remove-Item -Recurse -Force -WhatIf
Get-ChildItem $strFolder_180_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_180 } | Remove-Item -Recurse -Force -WhatIf


# Write-Host -foregroundcolor Yellow "================================================================================================="
#>
Write-Host -foregroundcolor Cyan "================================================================================================="
# Using the same script as above, delete the contents of the folders.
 
Write-Host -foregroundcolor Cyan "Now Cleaning Folders in $strComputer" 
# To identify the need if a User has access to a folder, we now put all the folders needing cleaing in an array and use `If Else` statements. 

$strFolders_0 = @()
$strFolders_0 += $strFolder_0_1
$strFolders_0 += $strFolder_0_2
$strFolders_0 += $strFolder_0_3
$strFolders_0 += $strFolder_0_4

foreach ($strFolder_0 in $strFolders_0)
{
    if (Test-Path $strFolder_0)
    {
        Remove-Item $strFolder_0\* -Recurse -Force
    }
    Else
    {
        Write-Host "Access denied on $strFolder_0" -ForegroundColor Red
    }
}

$strFolders_7 = @()
$strFolders_7 += $strFolder_7_1
$strFolders_7 += $strFolder_7_2

foreach ($strFolder_7 in $strFolders_7)
{
    if (Test-Path $strFolder_7)
    {
        Get-ChildItem $strFolder_7 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_7 } | Remove-Item -Recurse -Force
    }
    Else
    {
        Write-Host "Access denied on $strFolder_7" -ForegroundColor Red
    }
}

$strFolders_180 = @()
$strFolders_180 += $strFolder_180_1

foreach ($strFolder_180 in $strFolders_180)
{
    if (Test-Path $strFolder_180)
    {
        Get-ChildItem $strFolder_180 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_180 } | Remove-Item -Recurse -Force
    }
    Else
    {
        Write-Host "Access denied on $strFolder_180" -ForegroundColor Red
    }
}

$strFolders_270 = @()
$strFolders_270 += $strFolder_270_1

foreach ($strFolder_270 in $strFolders_270)
{
    if (Test-Path $strFolder_270)
    {
        Get-ChildItem $strFolder_270 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_270 } | Remove-Item -Recurse -Force
    }
    Else
    {
        Write-Host "Access denied on $strFolder_270" -ForegroundColor Red
    }
}

$strFolders_365 = @()
$strFolders_365 += $strFolder_365_1

foreach ($strFolder_365 in $strFolders_365)
{
    if (Test-Path $strFolder_365)
    {
        Get-ChildItem $strFolder_365 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_365 } | Remove-Item -Recurse -Force
    }
    Else
    {
        Write-Host "Access denied on $strFolder_365" -ForegroundColor Red
    }
}

<#
Remove-Item $strFolder_0_1\* -Recurse -Force
Remove-Item $strFolder_0_2\* -Recurse -Force
Remove-Item $strFolder_0_3\* -Recurse -Force
Remove-Item $strFolder_0_4\* -Recurse -Force
Get-ChildItem $strFolder_7_2 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_7 } | Remove-Item -Recurse -Force
Get-ChildItem $strFolder_7_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_7 } | Remove-Item -Recurse -Force
Get-ChildItem $strFolder_180_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_180 } | Remove-Item -Recurse -Force
Get-ChildItem $strFolder_270_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_270 } | Remove-Item -Recurse -Force
Get-ChildItem $strFolder_365_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_365 } | Remove-Item -Recurse -Force
#>

### PROFILE CLEAN UP ###
# Copy DelProf_2k8 to $strComputer
Write-Host -foregroundcolor Cyan "Now Copying DelProf_2k8 to $strComputer"
Copy-Item "\\$strFileRepo\DelProf_2k8.exe" "\\$strComputer\C$\Scripts\" |Out-Null

# Run DelProf_2k8
Write-Host -foregroundcolor Cyan "Now Running DelProf_2k8 on $strComputer"
Invoke-Command -ScriptBlock {c:\scripts\psexec.exe -accepteula \\$strComputer C:\scripts\delprof_2k8.exe} |Out-Null

### SEP CLEAN UP ###
# Copy RemoveStaleVirusDefs.exe to $strComputer
Write-Host -foregroundcolor Cyan "Now Copying RemoveStaleVirusDefs.exe to $strComputer"
Copy-Item "\\$strFileRepo\RemoveStaleVirusDefs.exe" "\\$strComputer\C$\Scripts\" |Out-Null

# Run RemoveStaleVirusDefs.exe
Write-Host -foregroundcolor Cyan "Now Running RemoveStaleVirusDefs.exe on $strComputer"
Invoke-Command -ScriptBlock {c:\scripts\psexec.exe -accepteula \\$strComputer C:\scripts\RemoveStaleVirusDefs.exe} |Out-Null

# Attempt to Empty the Recyclebin on the Remote Machine
Write-Host -foregroundcolor Cyan "Now Cleaning Recyclebin on $strComputer" 
Invoke-Command -ScriptBlock {c:\scripts\psexec.exe -accepteula \\$strComputer cmd.exe /c del /q /s /f c:\`$recycle.bin} | Out-Null

Write-Host -foregroundcolor Cyan "================================================================================================="

# Calculate the Free Space on "C"
$size = ([wmi]"\\$strComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'").Size
$free = ([wmi]"\\$StrComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'").FreeSpace
$disk = ([wmi]"\\$strComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'")
Write-Host -foregroundcolor Green "========================================AFTER CLEAN UP==========================================="
"$strComputer C: has {0:#.0} GB free of {1:#.0} GB Total" -f ($disk.FreeSpace/1GB),($disk.Size/1GB) | Write-Output
Write-Host -foregroundcolor Green "================================================================================================="

# Add in a Time Stamp
$strEndTime = Get-Date
$strEndTime | Out-Null
Write-Host "End Time"
(get-date).toString(‘HH:mm:ss MM-dd-yyyy’)
Write-Host -ForegroundColor Yellow "Time Spent: $($strEndTime - $strStartTime)"
}

#Functions
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
        RunCleanup -strComputer $Item
    }
    Else
    {
        Write-Host -ForegroundColor Red "Cannot Connect to $Item"
    }
}
