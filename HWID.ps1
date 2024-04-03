# Get the current location of the script
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Create a directory on the flash drive if it doesn't exist
$directoryPath = Join-Path $scriptPath "HWID"
New-Item -Type Directory -Path $directoryPath -Force

# Change the current location to the created directory
Set-Location -Path $directoryPath

# Add the script directory to the PATH environment variable
$env:Path += ";$scriptPath"

# Install the script (if not already installed)
Install-Script -Name Get-WindowsAutopilotInfo -Force

# Get the device serial number
$serialNumber = (Get-WmiObject -Class Win32_BIOS).SerialNumber

# Check if the serial number is not empty before using it
if (-not [string]::IsNullOrWhiteSpace($serialNumber)) {
    Write-Host "Device Serial Number: $serialNumber"

    # Specify the file path on the flash drive
    $filePath = Join-Path $directoryPath "AutopilotHWID.csv"

    # Run the script and save the output to the flash drive
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $scriptPath\Get-WindowsAutopilotInfo.ps1 -OutputFile $filePath" -Wait -PassThru

    # Specify the new file name with the serial number
    $newFileName = "AutopilotHWID_$serialNumber.csv"
    $newFilePath = Join-Path $directoryPath $newFileName

    # Rename the file
    Rename-Item -Path $filePath -NewName $newFileName -Force

    Write-Host "AutopilotHWID.csv saved to: $newFilePath"
} else {
    Write-Host "Unable to retrieve device serial number."
}
