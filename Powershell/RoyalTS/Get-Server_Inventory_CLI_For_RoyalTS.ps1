if ($args.Length -ne 1) {
Write-host "================================================="
Write-Host "Usage: In RoyalTS"
Write-Host -foregroundcolor Green "`tCreate a New Task"
Write-Host -foregroundcolor Cyan "`tSet the following:"
Write-Host -foregroundcolor Magenta "`t`tName: `t`t`t`tPowerShell: Server Inventory"
Write-Host -foregroundcolor Yellow "`t`tCommand: `t`t`tC:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
Write-Host -foregroundcolor Yellow "`t`tArgumnets: `t`t`t<PATH_SAVED>\Get-Server_Inventory_CLI_For_RoyalTS.ps1 `$URI$"
Write-Host -foregroundcolor Yellow "`t`tWorking Directory: `tC:\Windows\System32\WindowsPowerShell\v1.0"
Write-Host "Dont forget to check the box 'Show in Favorites'"
Write-host "================================================="
return
}

$strComputers = $args[0] 

foreach ($strComputer in $strComputers)
    {
    write-host -foregroundcolor green "====== Server Inventory of $strComputer ====="
    Get-wmiobject -Class Win32_Product -computer $strComputer | Select Name,Version | Sort-Object -Property Name | Out-GridView
    write-host -foregroundcolor green "====== END ====="
    }

Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
