# Create a directory if it doesn't exist and navigate to it
$directoryPath = "C:\HWID"
if (-not (Test-Path $directoryPath -PathType Container)) {
    New-Item -Type Directory -Path $directoryPath
}
Set-Location -Path $directoryPath

# Add the specified path to the environment variable
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"

# Set execution policy for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned

# Install the Get-WindowsAutopilotInfo script
Install-Script -Name Get-WindowsAutopilotInfo

# Get the serial number of the system
$serialNumber = Get-WmiObject -Class Win32_BIOS | Select-Object -ExpandProperty Serialnumber

# Define the output file name
$fileName = "AutopilotHWID_$serialNumber.csv"

# Run Get-WindowsAutopilotInfo and save the output to the specified file
Get-WindowsAutopilotInfo -OutputFile $fileName

# Copy the generated CSV file to the network location
$networkPath = "\\bhg-dav-fs01.bhg.com\software$\HWIDS"
if (Test-Path $networkPath) {
    Copy-Item "$directoryPath\*.csv" $networkPath
} else {
    Write-Host "Network path not found: $networkPath"
}