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
Write-Host "`tUsage: "
Write-Host -foregroundcolor Green "`t`t.\ListLocalAdmin.ps1"
Write-Host "`tExample(s):"
Write-Host -foregroundcolor Cyan "`t`t .\ListLocalAdmin.ps1"
Write-Host -foregroundcolor Cyan "`t`t C:\Scripts\Tools\PS1\LocalAdmin\ .\ListLocalAdmin.ps1"
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
