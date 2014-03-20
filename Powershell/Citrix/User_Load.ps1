[System.Reflection.Assembly]::LoadFile("C:\Program Files (x86)\Citrix\ICA Client\WfIcaLib.dll") 

function PowerLogin1 ($UserName,$Password,$ServerName,$Application)
{
    $ICA = New-Object WFICALib.ICAClientClass 
    $ICA.Address = $ServerName
    $ICA.Username = $UserName
    $ICA.InitialProgram = "#$Application"
    $ICA.SetProp("Password",$Password) 
    $ICA.Domain = "mmc"
    $ICA.Launch = $true
    $ICA.Connect()
}
$userlist = Import-Csv .\file.csv
foreach ($user in $userlist)
{
    #Below are the tables form the CSV
    PowerLogin1 -UserName $user.username -Password $user.password -ServerName $user.ServerName -Application $user.Application
    #$user.UserName
    #$user.Password
    #$user.ServerName
    $user.Application
    Start-Sleep -Seconds 4
}
