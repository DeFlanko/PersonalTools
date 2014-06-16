Function Get_Event_Log_Grabber($StrComputer){
    $Date = (Get-Date) - (New-TimeSpan -Day 30)
    Write-host -ForegroundColor Green "============ START of Event Log Grabber on $StrComputer ================"
    Write-host
    Write-host -ForegroundColor Green "Getting logs from $Date till now"
    Write-host
    Write-Host -ForegroundColor Cyan "Checking $StrComputer for the last 20 Logged on users"
        Get-WinEvent -Max 20 -ComputerName $StrComputer -FilterHashTable @{ Logname = "Security"; ID=528,4624} | Select TimeCreated, MachineName, @{n="LogonType";e={$_.Properties[8].Value}}, @{n='DomainName';e={$_.Properties[6].Value}}, @{n='AccountName';e={$_.Properties[5].Value}} |Format-List
    Write-host -ForegroundColor Cyan "Checking $StrComputer for Reboots and/or Shutdowns:"
        Get-WinEvent -ComputerName $StrComputer -FilterHashtable @{ LogName = "System"; StartTime = $Date; ID = 1074,1076,6006,6008}| Format-List
    Write-host -ForegroundColor Cyan "Checking $StrComputer for any NIC issues:"
        Get-WinEvent -ComputerName $StrComputer -FilterHashtable @{ LogName = "System"; StartTime = $Date; ProviderName = "*NIC*"}| Format-list
    Write-host -ForegroundColor Green "============ END of Event Log Grabber on $StrComputer ================"
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
                Get_Event_Log_Grabber -strComputer $Item
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
