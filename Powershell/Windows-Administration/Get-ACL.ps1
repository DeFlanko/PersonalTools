$userfolder = Get-Content "C:\Scripts\ACL\Users.txt" | % {
"\\molina.mhc\mhuser\CMC-Users\$_"}

$ACL = Get-Acl $Userfolder
$ACL | Select Path, Owner, AccessToString | Format-list
