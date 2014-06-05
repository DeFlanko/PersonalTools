<#  .Description
    A Function to look to a List of Servers in a TXT file to return Page File Values and Hard Disk values.
    
    .Example
        
    Inputbox of Servers
    
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

function Get-Server_Info ($Server){
    # Each Variable is its own call for the spreadsheet.
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
    $ServerVersions = @{
		'2250'='Whistler Server Preview';
		'2257'='Whistler Server Alpha';
		'2267'='Whistler Server interim release';
		'2410'='Whistler Server interim release';
		'5.1.2505'='Windows XP (RC 1)';
		#'5.1.2600'='Windows XP';
		'5.1.2600.1105-1106'='Windows XP, Service Pack 1';
		'5.1.2600.2180'='Windows XP, Service Pack 2';
		'5.1.2600'='Windows XP, Service Pack 3';
		'5.2.3541'='Windows .NET Server interim';
		'5.2.3590'='Windows .NET Server Beta 3';
		'5.2.3660'='Windows .NET Server Release Candidate 1 (RC1)';
		'5.2.3718'='Windows .NET Server 2003 RC2';
		'5.2.3763'='Windows Server 2003 (Beta?)';
		'5.2.3790'='Windows Server 2003';
		'5.2.3790.1180'='Windows Server 2003, Service Pack 1';
		'5.2.3790.1218'='Windows Server 2003';
		#'5.2.3790'='Windows Home Server';
		'6.0.5048'='Windows Longhorn';
		'6.0.5112'='Windows Vista, Beta 1';
		'6.0.5219'='Windows Vista, Community Technology Preview (CTP)';
		'6.0.5259'='Windows Vista, TAP Preview';
		'6.0.5270'='Windows Vista, CTP (Dezember)';
		'6.0.5308'='Windows Vista, CTP (Februar)';
		'6.0.5342'='Windows Vista, CTP (Refresh)';
		'6.0.5365'='Windows Vista, April EWD';
		'6.0.5381'='Windows Vista, Beta 2 Previw';
		'6.0.5384'='Windows Vista, Beta 2';
		'6.0.5456'='Windows Vista, Pre-RC1';
		'6.0.5472'='Windows Vista, Pre-RC1, Build 5472';
		'6.0.5536'='Windows Vista, Pre-RC1, Build 5536';
		'6.0.5600.16384'='Windows Vista, RC1';
		'6.0.5700'='Windows Vista, Pre-RC2';
		'6.0.5728'='Windows Vista, Pre-RC2, Build 5728';
		'6.0.5744.16384'='Windows Vista, RC2';
		'6.0.5808'='Windows Vista, Pre-RTM, Build 5808';
		'6.0.5824'='Windows Vista, Pre-RTM, Build 5824';
		'6.0.5840'='Windows Vista, Pre-RTM, Build 5840';
		'6.0.6000.16386'='Windows Vista, RTM (Release to Manufacturing)';
		'6.0.6000'='Windows Vista';
		#'6.0.6002'='Windows Vista, Service Pack 2';      
		'6.0.6001'='Windows Server 2008';
        '6.0.6002'='Windows Server 2008';
		#'6.1.7600.16385'='Windows 7, RTM (Release to Manufacturing)';
		#'6.1.7601'='Windows 7';
       	'6.1.7600'='Windows Server 2008 R2'
		'6.1.7600.16385'='Windows Server 2008 R2, RTM (Release to Manufacturing)';
		'6.1.7601'='Windows Server 2008 R2, SP1';
		'6.1.8400'='Windows Home Server 2011';
		'6.2.9200'='Windows Server 2012';
		#'6.2.9200'='Windows 8';
		'6.2.10211'='Windows Phone 8';
	}
    $Results = @()
    ForEach($OBJ in $Server){
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
            $Results += $TempOBJ
            $Results | Export-Csv .\Export.csv -Force -NoTypeInformation -Append
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

foreach ($Item in $ItemList){
    If($Item){
        Try{
            If (Test-Connection $Item -Count 1 -ErrorAction SilentlyContinue){
                Get-Server_Info -Server $Item
                }
            Else{
                Write-Host -ForegroundColor Magenta "======Ping Exception thrown on $Item ====="
                $Error[0].ToString()
                Write-Host -ForegroundColor Magenta "========^^^======="
                }
            }
        Catch [System.Management.Automation.PSArgumentException]{
            Write-Host -ForegroundColor Magenta "======Powershell Exception thrown on $Item ====="
            $ErrorMessage1 = $_.PSArgumentException.Message | Out-Host
            $FailedItem1 = $_.PSArgumentException.ItemName | Out-Host
            Write-Host -ForegroundColor Magenta "========^^^======="
            }
        Catch [System.Exception]{
            Write-Host -ForegroundColor Magenta "======System Exception thrown on $Item ====="
            $ErrorMessage2 = $_.Exception.Message | Out-Host
            $FailedItem2 = $_.Exception.ItemName | Out-Host
            Write-Host -ForegroundColor Magenta "========^^^======="
            }
        }
    }
Import-CSV .\Export.csv | Format-Table -Autosize
