# Define the Sophos installation directory
$sophosInstallDir = "C:\Program Files\Sophos\Sophos Endpoint Agent\"

# Check if the Sophos installation directory exists
if (Test-Path $sophosInstallDir) {
    Write-Host "Sophos installation directory found."

    # Define the uninstaller path
    $uninstallerPath = Join-Path $sophosInstallDir "SophosUninstall.exe"

    # Check if the uninstaller executable exists
    if (Test-Path $uninstallerPath) {
        Write-Host "Uninstaller found. Initiating uninstallation..."

        # Prompt for admin credentials
        $credentials = Get-Credential -Message "Enter your admin credentials"

        # Run the uninstaller as admin
        Start-Process -FilePath $uninstallerPath -Wait -Credential $credentials

        Write-Host "Uninstallation completed."
    } else {
        Write-Host "Error: Uninstaller not found at $uninstallerPath."
    }
} else {
    Write-Host "Error: Sophos installation directory not found at $sophosInstallDir."
}
