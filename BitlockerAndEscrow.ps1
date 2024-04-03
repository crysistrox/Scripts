# Step 1: Install Required Modules (if not already installed)
$AzureADModule = Get-Module -Name AzureAD -ListAvailable
$GraphIntuneModule = Get-Module -Name Microsoft.Graph.Intune -ListAvailable

if ($AzureADModule -eq $null) {
    Install-Module -Name AzureAD -Scope CurrentUser -Force
}

if ($GraphIntuneModule -eq $null) {
    Install-Module -Name Microsoft.Graph.Intune -Scope CurrentUser -Force
}

# Step 2: Connect to Azure AD
Connect-AzureAD

# Step 3: Retrieve BitLocker Recovery Keys for a Specific Device
$DeviceName = "YourDeviceName"  # Replace with the name of the device you want to retrieve the key for
$Device = Get-AzureADDevice -Filter "DisplayName eq '$DeviceName'"
if ($Device -eq $null) {
    Write-Host "Device not found."
    Disconnect-AzureAD
    Exit
}

# Step 4: Check if BitLocker is Enabled, and Enable It if Not
$BitLockerStatus = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftVolumeEncryption" -Class Win32_EncryptableVolume | Where-Object {$_.DriveLetter -ne $null}
if ($BitLockerStatus.Count -eq 0) {
    Write-Host "BitLocker is not enabled on this device. Enabling BitLocker..."
    Enable-BitLocker -MountPoint "C:" -RecoveryPasswordProtector -UsedSpaceOnly
    Write-Host "BitLocker has been enabled on the C: drive."
}

# Step 5: Retrieve BitLocker Recovery Keys (whether newly enabled or already enabled)
$RecoveryKeys = Get-AzureADBitlockerKey -ObjectId $Device.ObjectId

# Step 6: Output or Store the Keys (In this example, we'll output to the console)
if ($RecoveryKeys.Count -eq 0) {
    Write-Host "No BitLocker recovery keys found for $DeviceName."
} else {
    Write-Host "BitLocker Recovery Keys for $DeviceName:"
    foreach ($Key in $RecoveryKeys) {
        Write-Host "   Key ID: $($Key.KeyIdentifier)"
        Write-Host "   Recovery Key: $($Key.RecoveryPassword)"
        Write-Host "   --------------------------"
    }
}

# Step 7: Disconnect from Azure AD
Disconnect-AzureAD
