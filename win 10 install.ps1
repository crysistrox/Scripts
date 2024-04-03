# Specify the path to the WIM file
$wimPath = ""C:\Users\mcooper\Downloads\DIA_Dynamic_202212271825_VMWARE71.wim""

# Specify the drive letter of the USB drive
$usbDriveLetter = "F"

# Check if the WIM file exists
if (-not (Test-Path -Path $wimPath -PathType Leaf)) {
    Write-Host "WIM file not found: $wimPath"
    return
}

# Check if the USB drive exists
$usbDrive = Get-WmiObject -Class Win32_Volume | Where-Object {
    $_.DriveLetter -eq $usbDriveLetter -and $_.DriveType -eq 2
}

if (-not $usbDrive) {
    Write-Host "USB drive not found: $usbDriveLetter"
    return
}

# Format the USB drive
Write-Host "Formatting USB drive $usbDriveLetter..."
Format-Volume -DriveLetter $usbDriveLetter -FileSystem NTFS -Confirm:$false

# Create a partition on the USB drive
Write-Host "Creating partition on USB drive $usbDriveLetter..."
$disk = Get-Disk | Where-Object { $_.Number -eq $usbDrive.DiskIndex }
$partition = $disk | New-Partition -UseMaximumSize -AssignDriveLetter

# Format the partition on the USB drive
Write-Host "Formatting partition on USB drive $usbDriveLetter..."
Format-Volume -DriveLetter $partition.DriveLetter -FileSystem NTFS -Confirm:$false

# Mount the WIM file
Write-Host "Mounting WIM file..."
$mountPath = "C:\Mount"
New-Item -Path $mountPath -ItemType Directory | Out-Null
Dism /Mount-Wim /WimFile:$wimPath /Index:1 /MountDir:$mountPath

# Copy the contents of the WIM file to the USB drive
Write-Host "Copying files to USB drive..."
Copy-Item -Path "$mountPath\*" -Destination $partition.DriveLetter -Recurse -Force

# Dismount the WIM file
Write-Host "Dismounting WIM file..."
Dism /Unmount-Wim /MountDir:$mountPath /Commit

# Clean up
Write-Host "Cleaning up..."
Remove-Item -Path $mountPath -Force -Recurse

Write-Host "Bootable USB creation completed."
