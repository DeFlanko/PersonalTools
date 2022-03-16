Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
$null = $FileBrowser.ShowDialog()
Get-Content $FileBrowser.FileName | Set-Content -Encoding string $FileBrowser.FileName.Replace('.csv','_Converted.csv')
