$prefix = "BHG-"
$serialNumber = (Get-WmiObject Win32_BIOS).SerialNumber
$limitedSerial = $serialNumber.Substring(0, 7)  # Extract the first 7 characters

$newComputerName = "$prefix$limitedSerial"

Rename-Computer -NewName $newComputerName -Force
