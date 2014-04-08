<#  .Description
    A Function to look to a List of Servers in a TXT file to return Page File Values and Hard Disk values.
    
    .Example
        
    Get-PF_and_Disk_Report "LOCATION OF .TXT FILE"
    
    Output:

    Server          OS Version         PageFileLocation PageFileSize PhysicalMemory PF to Ram % Size of C - GB Free on C - GB % Free on C
    ------          ----------         ---------------- ------------ -------------- ----------- -------------- -------------- -----------
    Server1         Server 2008 R2 SP1 System Managed   1024         1023           0.0000 %    31.9           6.246          19.5800 %  
    Server2         Server 2008 SP2    System Managed   4394         4094           0.0000 %    79.998         10.027         12.5300 %  
    Server3         Server 2003 SP2    c:\pagefile.sys  7000         8191           85.4600 %   39.998         25.269         63.1800 %  
    Server4         Server 2012        c:\pagefile.sys  6144         8191           75.0000 %   59.655         35.916         60.2100 %  
        
    .Outputs
    One or more PSObjects with info about Page File Size, RAM, and Hard Disk to the Console window as well as to .\Export.csv
#>

function Get-PF_and_Disk_Report {
$Results = @()
Get-Content $args[0] | % {
     
    $Server = $_
    $OSVersion = Get-WmiObject -ComputerName $Server Win32_OperatingSystem | % {$_.Version}
    $PhysicalMem = Get-WmiObject -ComputerName $Server Win32_ComputerSystem | % {$_.TotalPhysicalMemory}
    $PhysicalMemVALUE = Get-WmiObject -ComputerName $Server Win32_ComputerSystem | % {[Math]::Round($PhysicalMem/1MB,0)}
    $PageFileType = Get-WmiObject -ComputerName $Server Win32_ComputerSystem | % {$_.AutomaticManagedPagefile}
    $PageFileLocation = Get-WmiObject -ComputerName $Server Win32_PageFile | % {$_.Name}
    $PageFileSize = Get-WmiObject -ComputerName $Server Win32_PageFile | % {[Math]::Round($_.FileSize/1MB,0)}
    $SM_Pagefilesize = Get-WmiObject -ComputerName $Server Win32_PageFileUsage | % {$_.AllocatedBaseSize} 
    $PFtoRAMPercent = Get-WmiObject -ComputerName $Server Win32_PageFile | % {"{0:P4}" -f [Math]::Round([Math]::round($_.FileSize/1MB,3)/[Math]::Round($PhysicalMem/1MB,3),4)}
    $SM_PFtoRAMPercent = Get-WmiObject -ComputerName $Server Win32_PageFileUsage | % {"{0:P4}" -f [Math]::Round([Math]::round($_.AllocatedBaseSize/1MB,3)/[Math]::Round($PhysicalMem/1MB,3),4)}
    $size = ([wmi]"\\$Server\root\cimv2:Win32_logicalDisk.DeviceID='c:'").Size
    $free = ([wmi]"\\$Server\root\cimv2:Win32_logicalDisk.DeviceID='c:'").FreeSpace
    $disk = ([wmi]"\\$Server\root\cimv2:Win32_logicalDisk.DeviceID='c:'")
    $SizeOnC = [Math]::Round($disk.Size/1GB,3)
    $FreeOnC = [Math]::Round($disk.FreeSpace/1GB,3)
    $PercentFreeOnC = "{0:P4}" -f [Math]::Round([Math]::Round($disk.FreeSpace/1GB,3)/[Math]::Round($disk.Size/1GB,3),4)
    
    $ServerVersions = @{ "6.2.9200"="Server 2012"; "6.1.7601"="Server 2008 R2 SP1"; "6.1.7600"="Server 2008 R2"; "6.0.6002"="Server 2008 SP2"; "5.2.3790"="Server 2003 SP2" }

ForEach($Item in $Server){
        $TempOBJ = New-Object PSObject
            If($PageFileType -eq "False")
                {
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Server" -Value $Server
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value ($ServerVersions["$OSVersion"])
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "PageFileLocation" -Value "System Managed"
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "PageFileSize" -Value $SM_Pagefilesize
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "PhysicalMemory" -Value $PhysicalMemVALUE
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "PF to Ram %" -Value $SM_PFtoRAMPercent
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Size of C - GB" -Value $SizeOnC
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Free on C - GB" -Value $FreeOnC
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "% Free on C" -Value $PercentFreeOnC
                }
            Else
                {
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Server" -Value $Server
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value ($ServerVersions["$OSVersion"])
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "PageFileLocation" -Value $PageFileLocation
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "PageFileSize" -Value $PageFileSize
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "PhysicalMemory" -Value $PhysicalMemVALUE
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "PF to Ram %" -Value $PFtoRAMPercent
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Size of C - GB" -Value $SizeOnC
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Free on C - GB" -Value $FreeOnC
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "% Free on C" -Value $PercentFreeOnC
                } 
            $results += $TempOBJ
            }
        }
$results | Export-Csv .\Export.csv -Force -NoTypeInformation
Import-CSV .\Export.csv | Format-Table -Autosize
}
