# Get the script directory using the $PSScriptRoot variable if available, or fallback to other methods
$scriptPath = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }

# Create a directory on the flash drive if it doesn't exist
$directoryPath = Join-Path $scriptPath "HWID"
New-Item -Type Directory -Path $directoryPath -Force | Out-Null

# Change the current location to the created directory
Set-Location -Path $directoryPath

# Add the script directory to the PATH environment variable
$env:Path += ";$scriptPath"

# Get the device serial number with error handling
try {
    $serialNumber = (Get-WmiObject -Class Win32_BIOS).SerialNumber
} catch {
    Write-Host "Error retrieving serial number: $_"
    $serialNumber = $null
}

# Check if the serial number is not empty before using it
if (-not [string]::IsNullOrWhiteSpace($serialNumber)) {
    Write-Host "Device Serial Number: $serialNumber"

    # Specify the file path on the flash drive
    $filePath = Join-Path $directoryPath "AutopilotHWID.csv"

    # Run the script and save the output to the flash drive
    $scriptFile = Join-Path $scriptPath "Get-WindowsAutopilotInfo.ps1"
    . $scriptFile -OutputFile $filePath

    # Specify the new file name with the serial number
    $newFileName = "AutopilotHWID_$serialNumber.csv"
    $newFilePath = Join-Path $directoryPath $newFileName

    # Rename the file
    Rename-Item -Path $filePath -NewName $newFileName -Force

    Write-Host "AutopilotHWID.csv saved to: $newFilePath"
} else {
    Write-Host "Unable to retrieve device serial number."
}
