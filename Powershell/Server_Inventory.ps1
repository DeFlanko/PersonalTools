$File = "<txt file goes here>"
$strComputers = Get-Content $File 

foreach ($strComputer in $strComputers)
    {
    write-host -foregroundcolor green "====== $strComputer ====="
    Get-wmiobject -Class Win32_Product -computer $strComputer
    write-host -foregroundcolor green "====== END ====="
    }
