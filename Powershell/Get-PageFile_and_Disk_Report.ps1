<#  .Description
    A Function to look to a List of Servers in a TXT file to return Page File Values and Hard Disk values.
    
    .Example
    Load Server names in TXT file specified then Run:
    Get-PF_and_Disk_Report "Selected Txt File"
    Output would be something like:
    
    Server          OS Version         PageFileLocation PageFileSize PhysicalMemory PF to Ram % Size of C - GB Free on C - GB % Free on C
    ------          ----------         ---------------- ------------ -------------- ----------- -------------- -------------- -----------
    SERVER1         Server 2003 SP2    c:\pagefile.sys  5000         8191           61.0400 %   39.998         27.223         68.0600 %  
    SERVER2         Server 2008 R2 SP1 System Managed   1024         1023           0.0000 %    31.9           6.246          19.5800 %  
    SERVER3         Server 2008 SP2    System Managed   4394         4094           0.0000 %    79.998         10.027         12.5300 %  
    SERVER4         Server 2012        c:\pagefile.sys  6144         8191           75.0000 %   59.655         35.909         60.1900 %  

    .Outputs
    One or more PSObjects with info about Page File Size, RAM, and Hard Disk as well as an "Export.csv" will be built. 
#>

function Get-PageFile_and_Disk_Report {
$Results = @()
Get-Content $args[0] | % {
    $Server = $_
        $Server2k12 = $_
        $Server2k8R2 = $_
        $Server2k8R2SP1 = $_
        $Server2k8SP2 =$_
        $Server2K3 = $_
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
    
ForEach($Item in $Server){
If($OSVersion -eq "6.2.9200"){
    Foreach ($Item in $Server2k12){
        $TempOBJ = New-Object PSObject
            If($PageFileType -eq "False")
                {
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Server" -Value $Server
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value "Server 2012"
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
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value "Server 2012"
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
ElseIf($OSVersion -eq "6.1.7601"){
    Foreach ($Item in $Server2k8R2SP1){
        $TempOBJ = New-Object PSObject
            If($PageFileType -eq "False")
                {
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Server" -Value $Server
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value "Server 2008 R2 SP1"
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
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value "Server 2008 R2 SP1"
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
ElseIf($OSVersion -eq "6.1.7600"){
    Foreach ($Item in $Server2k8R2){
        $TempOBJ = New-Object PSObject
            If($PageFileType -eq "False")
                {
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Server" -Value $Server
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value "Server 2008 R2"
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
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value "Server 2008 R2"
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
ElseIf($OSVersion -eq "6.0.6002"){
    Foreach ($Item in $Server2k8SP2){
        $TempOBJ = New-Object PSObject
                If($PageFileType -eq "False")
                {
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Server" -Value $Server
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value "Server 2008 SP2"
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
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value "Server 2008 SP2"
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
ElseIf($OSVersion -eq "5.2.3790"){
    Foreach ($Item in $Server2K3){
        $TempOBJ = New-Object PSObject
            If($PageFileType -eq "False")
                {
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "Server" -Value $Server
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value "Server 2003 SP2"
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
                $TempOBJ | Add-Member -MemberType NoteProperty -Name "OS Version" -Value "Server 2003 SP2"
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
    }
}
$results | Export-Csv C:\Scripts\netbackup\Export.csv -Force -NoTypeInformation
Import-CSV C:\Scripts\netbackup\Export.csv | Format-Table -Autosize
}
