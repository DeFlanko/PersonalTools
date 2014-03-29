# To Suppress the Red Errors \\ Remove if you need to see errors. 
$ErrorActionPreference = "SilentlyContinue"
#$ErrorActionPreference = "Continue"

function RunCleanup ($strComputer)
{
# Add in a Time Stamp
Write-Host "Start Time"
(get-date).toString(‘HH:mm:ss MM-dd-yyyy’)

# Static Locations
    $strFileRepo = "mhcalbsysadpv01\SysAdmins\Scripts\Powershell_Scripts\Clean_C_Drive"

# Clean Files older than 0 Days
    $strFolder_0_1 = "\\$strComputer\C$\Temp" 
    $strFolder_0_2 = "\\$strComputer\C$\Windows\Temp"
    $strFolder_0_3 = "\\$strComputer\C$\Windows\SoftwareDistribution\Download"
    $strFolder_0_4 = "\\$strComputer\C$\Windows\ProPatches\Patches"
        
# Clean files older than 7 days
    $strFolder_7_1 = "\\$strComputer\C$\ProgramData\Microsoft Visual Studio\10.0\TraceDebugging"
    $strFolder_7_2 = "\\$strComputer\C$\inetpub\logs\LogFiles"

# Clean files older than 180 days
    $strFolder_180_1 = "\\$strComputer\C$\Program Files\Microsoft SQL Server\100\Setup Bootstrap\Update Cache"

# Clean files older than 270 days
    $strFolder_270_1 = "\\$strComputer\C$\Windows\Installer"
    
# Clean files older than 365 days
    $strFolder_365_1 = "\\$strComputer\C$\PerfLogs"

# Determine how far back we go based on current date
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

Write-Host -foregroundcolor Yellow "=======================================FILES TO BE CLEANED======================================"
Write-Host -foregroundcolor Yellow "Now Identifying Sizes of Folders in $strComputer"

# Identify the folders we want to Measure and their contents.

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



# Sum up the totals of the above

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

# Process the report: group by 'Item' then sum 'Average' for each group and create the Summed Output in GB

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

Write-Host -foregroundcolor Yellow "================================================================================================"
Write-Host -foregroundcolor Cyan "================================================================================================"
# Using the same script as above, delete the contents of the folders.
 
Write-Host -foregroundcolor Cyan "Now Cleaning Folders in $strComputer" 

Remove-Item $strFolder_0_1\* -Recurse -Force
Remove-Item $strFolder_0_2\* -Recurse -Force
Remove-Item $strFolder_0_3\* -Recurse -Force
Remove-Item $strFolder_0_4\* -Recurse -Force
Get-ChildItem $strFolder_7_2 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_7 } | Remove-Item -Recurse -Force
Get-ChildItem $strFolder_7_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_7 } | Remove-Item -Recurse -Force
Get-ChildItem $strFolder_270_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_270 } | Remove-Item -Recurse -Force
Get-ChildItem $strFolder_365_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_365 } | Remove-Item -Recurse -Force
Get-ChildItem $strFolder_180_1 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_180 } | Remove-Item -Recurse -Force

### PROFILE CLEAN UP ###
# Copy DelProf_2k8 to $strComputer
Write-Host -foregroundcolor Cyan "Now Copying DelProf_2k8 to $strComputer"
Copy-Item "\\$strFileRepo\DelProf_2k8.exe" "\\$strComputer\C$\Scripts\"

# Run DelProf_2k8
Write-Host -foregroundcolor Cyan "Now Running DelProf_2k8 on $strComputer"
Invoke-Command -ScriptBlock {c:\scripts\psexec.exe -accepteula \\$strComputer C:\scripts\delprof_2k8.exe}

### SEP CLEAN UP ###
# Copy RemoveStaleVirusDefs.exe to $strComputer
Write-Host -foregroundcolor Cyan "Now Copying RemoveStaleVirusDefs.exe to $strComputer"
Copy-Item "\\$strFileRepo\RemoveStaleVirusDefs.exe" "\\$strComputer\C$\Scripts\"

# Run RemoveStaleVirusDefs.exe
Write-Host -foregroundcolor Cyan "Now Running RemoveStaleVirusDefs.exe on $strComputer"
Invoke-Command -ScriptBlock {c:\scripts\psexec.exe -accepteula \\$strComputer C:\scripts\RemoveStaleVirusDefs.exe}

# Attempt to Empty the Recyclebin on the Remote Machine
Write-Host -foregroundcolor Cyan "Now Cleaning Recyclebin on $strComputer" 
Invoke-Command -ScriptBlock {c:\scripts\psexec.exe -accepteula \\$strComputer cmd.exe /c del /q /s /f c:\`$recycle.bin} 

Write-Host -foregroundcolor Cyan "================================================================================================"

# Calculate the Free Space on "C"
$size = ([wmi]"\\$strComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'").Size
$free = ([wmi]"\\$StrComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'").FreeSpace
$disk = ([wmi]"\\$strComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'")
Write-Host -foregroundcolor Green "========================================AFTER CLEAN UP=========================================="
"$strComputer C: has {0:#.0} GB free of {1:#.0} GB Total" -f ($disk.FreeSpace/1GB),($disk.Size/1GB) | Write-Output
Write-Host -foregroundcolor Green "================================================================================================"

# Add in a Time Stamp
Write-Host "End Time"
(get-date).toString(‘HH:mm:ss MM-dd-yyyy’)
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
    RunCleanup -strComputer $Item
} 
