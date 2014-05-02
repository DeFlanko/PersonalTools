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
#sets ARGS.. if you want to manually specify a list other than ".\ADDSERVERS.txt" then change ARGS to 2 and specify at the end...
if ($args.Length -ne 1) {
Write-host "================================================="
Write-Host "`tUsage: "
Write-Host -foregroundcolor Green "`t`t.\ADDLocalAdmin.ps1" "(UserName) or (Security Group)"
Write-Host "`tExample(s):"
Write-Host -foregroundcolor Cyan "`t`t .\ADDLocalAdmin.ps1" "(UserName) or (Security Group)" 
Write-Host -foregroundcolor Cyan "`t`t C:\Scripts\Tools\PS1\LocalAdmin\ADDLocalAdmin.ps1" "(UserName) or (Security Group)"
Write-host "================================================="
return
}
#Your domain, change this
$domain = "MMC"
#Get the user to add
$username = $args[0]
#File to read computer list from
$strComputers = Get-content "C:\Scripts\Tools\PS1\LocalAdmin\ADDSERVERS.txt"
foreach ($strComputer in $strComputers)
{ 
if (Ping-Server($strComputer)) { 
$computer = [ADSI]("WinNT://" + $strComputer + ",computer")
$GroupName = "Administrators"
$Group = $computer.psbase.children.find($Groupname)
# This will list what’s currently in Administrator Group so you can verify the result
write-host -foregroundcolor green "====== $strComputer $GroupName BEFORE ====="
ListAdministrators $Group
write-host -foregroundcolor green "====== BEFORE ====="
# Even though we are adding the AD account
# It is being added to the local computer and so we will need to use WinNT: provider 
$Group.Add("WinNT://" + $domain + "/" + $username) 
write-host -foregroundcolor green "====== $strComputer $GroupName AFTER ====="
ListAdministrators $Group
write-host -foregroundcolor green "====== AFTER ====="
}
else
{
write-host -foregroundcolor red "$strComputer is not pingable"
}
}
