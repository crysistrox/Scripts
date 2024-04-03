# Check if the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run the script as an administrator."

    # Relaunch the script with elevated privileges
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs

    Exit
}

# Admin credentials (replace 'adminusername' and 'adminpassword' with your actual admin credentials)
$adminUsername = "TSOAdmin"
$adminPassword = ConvertTo-SecureString "DT2,m[t)7}{5R+" -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential($adminUsername, $adminPassword)

# Check if Winget is installed
$wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue

if ($wingetInstalled -eq $null) {
    # Winget is not installed, download and install from GitHub release
    Write-Host "Winget is not installed. Installing..."

    # Download the Winget appxbundle using WebClient
    $wingetInstallerUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle"
    $wingetInstallerPath = "$env:USERPROFILE\Downloads\winget.appxbundle"

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($wingetInstallerUrl, $wingetInstallerPath)
    } catch {
        Write-Host "Failed to download the Winget appxbundle. Please check your internet connection or download it manually."
        Exit
    }

    # Install Winget using the downloaded appxbundle
    Add-AppxPackage -Path $wingetInstallerPath

    # Check if installation was successful
    $wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetInstalled -eq $null) {
        Write-Host "Failed to install Winget. Please install it manually."
        Exit
    }

    Write-Host "Winget installed successfully."

    # Run Winget silently
    Write-Host "Running Winget silently..."
    Start-Process -FilePath 'winget' -ArgumentList "upgrade --all --silent --accept-package-agreements --accept-source-agreements --force -y" -Credential $adminCredential -Wait
    Write-Host "Winget upgrade completed."
}

# Install Loom using Winget
Write-Host "Installing Loom..."
Start-Process -FilePath 'winget' -ArgumentList "install -e --id Loom.Loom -y" -Credential $adminCredential -Wait

Write-Host "Loom installation completed."
