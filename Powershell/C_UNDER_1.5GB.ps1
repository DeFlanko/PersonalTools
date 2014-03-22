# To Suppress the Red Errors \\ Remove if you need to see errors. 
$ErrorActionPreference = "SilentlyContinue"

# Script to resolve "User partition less than 1.5 GB" - remotly Clean PC's
$strComputer = Read-Host "Enter the Server you wish to connect to"

# Add in a Time Stamp
Write-Host "Start Time"
(get-date).toString(‘HH:MM:ss mm-dd-yyyy’)

#Per Ricky
    $strFolder1 = "\\$strComputer\C$\inetpub\logs\LogFiles" 
    $strFolder2 = "\\$strComputer\C$\Temp"
    $strFolder3 = "\\$strComputer\C$\Windows\Temp"
    $strFolder4 = "\\$strComputer\C$\Windows\SoftwareDistribution\Download"
    $strFolder5 = "\\$strComputer\C$\Windows\ProPatches\Patches"

# Per Phillip
    #files older than 7 days
    $strFolder6 = "\\$strComputer\C$\ProgramData\Microsoft Visual Studio\10.0\TraceDebugging"
    #files older than 9 months
    $strFolder7 = "\\$strComputer\C$\Windows\Installer"

# Per James	
    $strFolder8 = "\\$strComputer\C$\`$Recycle.bin"
    $strFolder9 = "\\$strComputer\C$\PerfLogs"

# determine how far back we go based on current date
    $curr_date = Get-Date
    $max_days_7 = "-7"
    $del_date_7 = $curr_date.AddDays($max_days_7)
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

Write-Host -foregroundcolor Yellow "================================================================================================="
Write-Host -foregroundcolor Yellow "Now Identifying Sizes of Folders in $strComputer"

# We identify the folders we want to Measure and their contents.
$colItems1 = (Get-ChildItem $strFolder1 -recurse | Measure-Object -property length -sum )
"$strFolder1 is {0:N2}" -f ($colItems1.sum / 1GB) + " GB"
$colItems2 = (Get-ChildItem $strFolder2 -recurse | Measure-Object -property length -sum)
"$strFolder2 is {0:N2}" -f ($colItems2.sum / 1GB) + " GB"
$colItems3 = (Get-ChildItem $strFolder3 -recurse | Measure-Object -property length -sum)
"$strFolder3 is {0:N2}" -f ($colItems3.sum / 1GB) + " GB"
$colItems4 = (Get-ChildItem $strFolder4  -recurse | Measure-Object -property length -sum)
"$strFolder4 is {0:N2}" -f ($colItems4.sum / 1GB) + " GB"
$colItems5 = (Get-ChildItem $strFolder5 -recurse | Measure-Object -property length -sum)
"$strFolder5 is {0:N2}" -f ($colItems5.sum / 1GB) + " GB"
$colItems6 = (Get-ChildItem $strFolder6 -recurse | Measure-Object -property length -sum)
"$strFolder6 is {0:N2}" -f ($colItems6.sum / 1GB) + " GB"
$colItems7 = (Get-ChildItem $strFolder7 -recurse | Measure-Object -property length -sum)
"$strFolder7 is {0:N2}" -f ($colItems7.sum / 1GB) + " GB"
$colItems8 = (Get-ChildItem $strFolder8 -recurse | Measure-Object -property length -sum)
"$strFolder8 is {0:N2}" -f ($colItems8.sum / 1GB) + " GB"
$colItems9 = (Get-ChildItem $strFolder9 -recurse | Measure-Object -property length -sum)
"$strFolder9 is {0:N2}" -f ($colItems9.sum / 1GB) + " GB"


#Now we sum up the totals -- This part is not shown // Also not too sure if its needed... 

$report = @(
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems1.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems2.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems3.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems4.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems5.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems6.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems7.sum / 1GB) }
	New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems8.sum / 1GB) }
    New-Object psobject -Property @{ Item = "Size In GB"; Average = "{0:N2}" -f ($colItems9.sum / 1GB) }
)

# process: group by 'Item' then sum 'Average' for each group and create the Summed Output in GB

 $report | Group-Object Item | %{
     New-Object psobject -Property @{
         Item = $_.Name
        Sum = ($_.Group | Measure-Object Average -Sum).Sum
     }
 }
Write-Host -foregroundcolor Yellow "=======================================FILES TO BE CLEANED======================================"

Remove-Item $strFolder1\* -Recurse -Force -WhatIf
Remove-Item $strFolder2\* -Recurse -Force -WhatIf
Remove-Item $strFolder3\* -Recurse -Force -WhatIf
Remove-Item $strFolder4\* -Recurse -Force -WhatIf
Remove-Item $strFolder5\* -Recurse -Force -WhatIf
Get-ChildItem $strFolder6 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_7 } | Remove-Item -Recurse -Force -WhatIf
Get-ChildItem $strFolder7 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_270 } | Remove-Item -Recurse -Force -WhatIf
Get-ChildItem $strFolder9 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_365 } | Remove-Item -Recurse -Force -WhatIf

# Now we delete the contents of the folders. To test the folder add "-whatif" at the end.
Write-Host -foregroundcolor Cyan "Now Cleaning Folders in $strComputer" 

Remove-Item $strFolder1\* -Recurse -Force
Remove-Item $strFolder2\* -Recurse -Force
Remove-Item $strFolder3\* -Recurse -Force
Remove-Item $strFolder4\* -Recurse -Force
Remove-Item $strFolder5\* -Recurse -Force
Get-ChildItem $strFolder6 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_7 } | Remove-Item -Recurse -Force
Get-ChildItem $strFolder7 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_270 } | Remove-Item -Recurse -Force
Get-ChildItem $strFolder9 -Recurse | Where-Object { $_.LastWriteTime -lt $del_date_365 } | Remove-Item -Recurse -Force

# Attempt to Empty the Recyclebin on the Remote Machine
Write-Host -foregroundcolor Cyan "Now Cleaning Recyclebin on $strComputer" 
Invoke-Command -ScriptBlock {c:\scripts\psexec.exe -accepteula \\$strComputer cmd.exe /c del /q /s /f c:\`$recycle.bin} 

# Run DelProf_2k8
Write-Host -foregroundcolor Cyan "Now Running DelProf_2k8 on $strComputer"
Invoke-Command -ScriptBlock {c:\scripts\psexec.exe -accepteula \\$strComputer C:\scripts\delprof_2k8.exe}

# Calculate the Free Space on "C"
$size = ([wmi]"\\$strComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'").Size
$free = ([wmi]"\\$StrComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'").FreeSpace
$disk = ([wmi]"\\$strComputer\root\cimv2:Win32_logicalDisk.DeviceID='c:'")
Write-Host -foregroundcolor Green "========================================AFTER CLEAN UP==========================================="
"$strComputer C: has {0:#.0} GB free of {1:#.0} GB Total" -f ($disk.FreeSpace/1GB),($disk.Size/1GB) | Write-Output
Write-Host -foregroundcolor Green "================================================================================================="

# Add in a Time Stamp
Write-Host "End Time"
(get-date).toString(‘HH:MM:ss mm-dd-yyyy’)