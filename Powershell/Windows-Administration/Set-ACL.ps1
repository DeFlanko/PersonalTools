######Please change the path of the users folder if different then that listed. 
#For testing: 
#$FlatFile = Get-Content "C:\Scripts\ACL\me.txt"
#$RootPath = "C:\Scripts\ACL"

#For UAT:
$FlatFile = Get-Content "C:\Scripts\ACL\TEST.txt"
$RootPath = "\\Fileshare\Folder

#For Production:
#$FlatFile = Get-Content "C:\Scripts\ACL\Users.txt"
#$RootPath = "\\Fileshare\Folder"

#The possible values for $Rights are 
# ListDirectory, ReadData, WriteData 
# CreateFiles, CreateDirectories, AppendData 
# ReadExtendedAttributes, WriteExtendedAttributes, Traverse
# ExecuteFile, DeleteSubdirectoriesAndFiles, ReadAttributes 
# WriteAttributes, Write, Delete 
# ReadPermissions, Read, ReadAndExecute 
# Modify, ChangePermissions, TakeOwnership
# Synchronize, FullControl

$Rights = "Modify"

Foreach($User in $FlatFile){
    $path = "$RootPath" + "\" + "$User"
    $Acl = Get-Acl $path
    Write-host -ForegroundColor Green "========================= $Path BEFORE ========================="
    $ACL | Select Path, Owner, AccessToString | Format-list
    Write-host -ForegroundColor Green "================================================================================="
    $Ar = New-Object  system.security.accesscontrol.filesystemaccessrule($User,$Rights,"ContainerInherit, ObjectInherit", "None", "Allow")
    $Acl.SetAccessRule($Ar)
    Set-Acl $path $Acl | Out-Host
    Write-host -ForegroundColor Green "========================= $Path AFTER ========================="
    $ACL | Select Path, Owner, AccessToString | Format-list
    Write-host -ForegroundColor Green "================================================================================="
    }
