$timeout = New-TimeSpan -Minutes 60  # Set the timeout to 60 minutes
$timeoutSeconds = $timeout.TotalSeconds
$startTime = Get-Date

# Specify the username and password
$username = "mcooperadmin"
$password = ConvertTo-SecureString "V3nom0908#" -AsPlainText -Force

# Define the path for the log file on the desktop
$logFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop), "ScriptLog.txt")

# Function to write log entries
function Write-LogEntry {
    param (
        [string]$logMessage
    )

    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $logMessage"
    $logEntry | Out-File -Append -FilePath $logFilePath
}

# Start logging
Write-LogEntry "Script started."

$scriptBlock = {
    # Check if the PowerShellGet module is installed
    if (!(Get-Module -ListAvailable -Name PowerShellGet)) {
        # Install the PowerShellGet module
        if (!(Test-Path "$env:ProgramFiles\PackageManagement\PackageManagement.psm1")) {
            # Install the NuGet provider if not already installed
            Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
        }

        # Install the PowerShellGet module
        Install-Module -Name PowerShellGet -Force -AllowClobber -Scope AllUsers -SkipPublisherCheck
    }

    # Add a delay of 120 seconds (2 minutes) between the installations
    Start-Sleep -Seconds 120

    # Install the Persistence Sniper module without confirmation prompts
    Install-Module -Name PersistenceSniper -Force -AllowClobber -Scope AllUsers -SkipPublisherCheck -Verbose *> $null
}

# Try running the script block and log any errors
try {
    # Execute the script block
    Invoke-Command -ScriptBlock $scriptBlock

    # Log success
    Write-LogEntry "Script execution completed successfully."
}
catch {
    # Log errors
    Write-LogEntry "Error: $($_.Exception.Message)"
}

# End logging
Write-LogEntry "Script finished."

# Display the log file path
Write-Host "Log file saved to: $logFilePath"
