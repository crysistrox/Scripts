# Check if BitLocker is turned on
$bitlockerStatus = Get-BitLockerVolume

if ($bitlockerStatus.ProtectionStatus -eq "On") {
    Write-Host "BitLocker is already turned on."
}
else {
    Write-Host "BitLocker is not turned on. Turning it on..."

    # Enable BitLocker (default encryption method)
    Enable-BitLocker -MountPoint "C:"

    Write-Host "BitLocker is now turned on."
}
