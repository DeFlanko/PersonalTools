Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Where-Object PSPath -Like "*.bak" | Remove-Item -Recurse -Force -whatif
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Where-Object PSPath -Like "*.bak" | Remove-Item -Recurse -Force 
