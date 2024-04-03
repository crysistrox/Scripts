# Check if the script is running with administrator privileges
$isAdmin = ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script requires administrator privileges. Restarting with elevated privileges..."
    
    # Restart the script with elevated privileges
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$timeout = New-TimeSpan -Minutes 60  # Set the timeout to 60 minutes

# Define the script block to be executed
$scriptBlock = {
    # Check if the PowerShellGet module is installed
    if (!(Get-Module -ListAvailable -Name PowerShellGet)) {
        # Install the PowerShellGet module
        if (!(Test-Path "$env:ProgramFiles\PackageManagement\PackageManagement.psm1")) {
            # Install the NuGet provider if not already installed
            Install-PackageProvider -Name NuGet -Force -Scope AllUsers
        }

        # Install the PowerShellGet module
        Install-Module -Name PowerShellGet -Force -AllowClobber -Scope AllUsers -SkipPublisherCheck -Repository PSGallery
    }

    # Add a delay of 120 seconds (2 minutes) between the installations
    Start-Sleep -Seconds 120

    # Install the Persistence Sniper module without confirmation prompts
    Install-Module -Name PersistenceSniper -Force -AllowClobber -Scope AllUsers -SkipPublisherCheck -Repository PSGallery -Verbose *> $null

    # Import the Persistence Sniper module
    Import-Module -Name PersistenceSniper -Force
}

try {
    $result = Start-Timeout -Timeout $timeout -ScriptBlock $scriptBlock
    # Process the result of the script execution
} catch {
    # Handle the timeout error here
    Write-Host "Script execution timed out."
}
