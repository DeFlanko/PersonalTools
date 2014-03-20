$StrComputer = "."
$names = gwmi Win32_USBControllerDevice |%{[wmi]($_.Dependent)} | Where-Object { $_.Service -match 'usbvideo' }

Foreach ($name in $names){
#Capture the "Name" Variable of the USBVIDEO 
    $foldername =$name.Name
#Build the folder - Overwriting any Existing
    New-Item -ItemType directory -Path "C:\Windows\twain_32\" -name "$foldername" -Force
#Copy the TWAIN2080.ds to the newly created folder
    Copy-Item -Path ".\TWAIN2080.ds" -Destination "C:\Windows\twain_32\$foldername"
}
