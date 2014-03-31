function ListAdministrators($Group)
{
    $members= $Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $members
}
function Ping-Server {
    Param([string]$srv)
    $pingresult = Get-WmiObject Win32_PingStatus -Filter "Address='$srv'"
    if($pingresult.StatusCode -eq 0) {$true} else {$false}
}

if ($args.Length -ne 1) {
Write-host "================================================="
Write-Host "Usage: In RoyalTS"
Write-Host -foregroundcolor Green "`tCreate a New Task"
Write-Host -foregroundcolor Cyan "`tSet the following:"
Write-Host -foregroundcolor Magenta "`t`tName: `t`t`t`tPowerShell: List Local Admin"
Write-Host -foregroundcolor Yellow "`t`tCommand: `t`t`tC:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
Write-Host -foregroundcolor Yellow "`t`tArgumnets: `t`t`t<PATH_SAVED>\ListLocalAdmin_CLI_For_RoyalTS.ps1 `$URI$"
Write-Host -foregroundcolor Yellow "`t`tWorking Directory: `tC:\Windows\System32\WindowsPowerShell\v1.0"
Write-host "================================================="
return
}

#Your domain
$domain = "MMC"
$strComputers = $args[0]

foreach ($strComputer in $strComputers){

if (Ping-Server($strComputer)) { 
    $computer = [ADSI]("WinNT://" + $strComputer + ",computer")
    $GroupName = "Administrators"
    $Group = $computer.psbase.children.find($Groupname)

# This will list what’s currently in Administrator Group
    write-host -foregroundcolor green "====== $strComputer $Groupname List ====="
    ListAdministrators $Group
    write-host -foregroundcolor green "====== END ====="
}
else
   {
   write-host -foregroundcolor red "$strComputer is not pingable"
   }
}
Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
