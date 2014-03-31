if ($args.Length -ne 1) {
Write-host "================================================="
Write-Host "Usage: In RoyalTS"
Write-Host -foregroundcolor Green "`tCreate a New Task"
Write-Host -foregroundcolor Cyan "`tSet the following:"
Write-Host -foregroundcolor Magenta "`t`tName: `t`t`t`tPowerShell: Get Server UpTime"
Write-Host -foregroundcolor Yellow "`t`tCommand: `t`t`tC:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
Write-Host -foregroundcolor Yellow "`t`tArgumnets: `t`t`t<PATH_SAVED>\Get-ServerUpTime_CLI_For_RoyalTS.ps1 `$URI$"
Write-Host -foregroundcolor Yellow "`t`tWorking Directory: `tC:\Windows\System32\WindowsPowerShell\v1.0"
Write-Host "Dont forget to check the box 'Show in Favorites'"
Write-host "================================================="
return
}

$Servers = $args[0]

ForEach ($Server in $Servers)
{
 #First see if server is online
 if (Test-Connection -Quiet -Count 1 -ComputerName $Server -ErrorAction SilentlyContinue) 
 {
  
  # Get today’s date
  $Today = Get-Date

  # Get the WMI object for the start time
  $A = Get-WmiObject win32_operatingsystem -ComputerName $Server
  
  # Obtain the Boot time in .NET format
  $BootTime = $A.ConverttoDateTime($A.LastBootupTime)
  
  # Calculate how many days the system has been up
  $Uptime=$Today-$Boottime
 
  # Obtain all the data for the output string
  $Days=$Uptime.Days
  $Hours=$Uptime.Hours
  $Minutes=$Uptime.Minutes
  $Seconds=$Uptime.Seconds
  #$JustDate=$Today.toshortdatestring()
  $JustTime=$Today.toshorttimestring()
  
  # Machine may be pingable but may hung or in process of process of being shut down so check if $Seconds has a zero length
  IF( $Seconds.length -EQ 0 )
   {
   Write-Host ”As of $JustTime $Server has been up for $Days days, $Hours hours, $Minutes minutes” -ForegroundColor Green 
   Write-Host "*********** $Server is pingable but is not responding with a valid uptime --> Manually check if being shutdown or is hung ************" -ForegroundColor Magenta -BackgroundColor DarkMagenta
   }

 Write-Host "========================================================================================" -ForegroundColor Green -BackgroundColor Black
 Write-Host `t`t”As of $JustTime $Server has been up for $Days days, $Hours hours, $Minutes minutes”`t`t -ForegroundColor Green -BackgroundColor Black
 Write-Host "========================================================================================" -ForegroundColor Green -BackgroundColor Black
 }
 ELSE
 {
  Write-Host "============================================================================================" -ForegroundColor Yellow -BackgroundColor Red
  Write-Host `t`t`t`t`t`t`t"****  $Server is OFFLINE  ****"`t`t`t`t`t`t`t -ForegroundColor Yellow -BackgroundColor Red
  Write-Host "============================================================================================" -ForegroundColor Yellow -BackgroundColor Red
 }
}
Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
