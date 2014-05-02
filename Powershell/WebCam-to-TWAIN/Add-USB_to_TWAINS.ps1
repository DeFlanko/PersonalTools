$StrComputer = "."
#Originally tried using { $_.service -match 'usbvideo' } but the Logitech C525 shows up as "LVUVC64" so that could not be used.
$names = gwmi Win32_USBControllerDevice |%{[wmi]($_.Dependent)} | Where-Object { $_.name -match 'webcam' }

Foreach ($name in $names){
#Capture the "Name" Variable of the USBVIDEO 
    $foldername =$name.Name
    #Write-Host $foldername
#Build the folder - Overwriting any Existing
    New-Item -ItemType directory -Path "C:\Windows\twain_32\" -name "$foldername" -Force
#Copy the TWAIN2080.ds to the newly created folder
## You may have ot change the path to where ever the ds is located on the packageing server. 
    Copy-Item -Path ".\TWAIN2080.ds" -Destination "C:\Windows\twain_32\$foldername"
}
