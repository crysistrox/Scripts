# Stop the PanGPS service
Stop-Service -Name PanGPS

# Define the registry paths and portal names
$baseKey = "HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect"
$currentPortal = (Get-ItemProperty -Path "$baseKey\PanSetup").Portal
$basePortal = "rm.bhg-inc.com"
$newPortalName = "bhgvpn.bhg-inc.com"

# Registry path for the local machine settings
$localMachineKey = "HKLM:\Software\Palo Alto Networks\GlobalProtect\Settings"

# Registry path for the current user settings
$currentuserKey = "HKCU:\Software\Palo Alto Networks\GlobalProtect\Settings\$newPortalName"

# Check if the current portal is not the correct one, then update
if ($currentPortal -ne $newPortalName) {
    # Remove the old registry key
    $oldRegistryKey = Join-Path $baseKey "Settings\$basePortal"
    Remove-Item -Path $oldRegistryKey -Force

    # Add the new registry key
    $newRegistryKey = Join-Path $baseKey "Settings\$newPortalName"
    New-Item -Path $newRegistryKey -Force

    # Add a DWORD value named "uninstall"
    $uninstallValuePath = Join-Path $newRegistryKey "uninstall"
    New-ItemProperty -Path $newRegistryKey -Name "uninstall" -Value 1 -PropertyType DWORD -Force

    # Modify the registry entry
    Set-ItemProperty -Path "$baseKey\PanSetup" -Name "Portal" -Value $newPortalName

    # Change the value of the LastUrl string in the local machine settings
    Set-ItemProperty -Path $localMachineKey -Name "LastUrl" -Value $newPortalName
}

# Add the new registry key under the current user settings
New-Item -Path $currentuserKey -Force

# Start the PanGPS service
Start-Service -Name PanGPS
