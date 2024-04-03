# Get the device serial number dynamically (assuming it's available in a WMI property)
$DeviceSerialNumber = (Get-WmiObject Win32_BIOS).SerialNumber

# Trim the serial number if it's longer than 11 characters
if ($DeviceSerialNumber.Length -ge 12) {
    $DeviceSerialNumber = $DeviceSerialNumber.Substring($DeviceSerialNumber.Length - 11)
}

# Construct the new computer name with the desired format
$NewComputerName = "BHG-$DeviceSerialNumber"

# Change the computer name
Rename-Computer -NewName $NewComputerName -Force

Write-Host "Computer name changed to $NewComputerName."
