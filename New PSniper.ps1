$timeout = New-TimeSpan -Minutes 60  # Set the timeout to 60 minutes
$timeoutSeconds = $timeout.TotalSeconds
$startTime = Get-Date

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

    # Import the Persistence Sniper module
    Import-Module -Name PersistenceSniper -Force
}

# Execute the script block
$job = Start-Job -ScriptBlock $scriptBlock
$completed = $job | Wait-Job -Timeout $timeoutSeconds

if (!$completed) {
    # The script execution timed out
    Stop-Job -Job $job
    Write-Host "Script execution timed out."
} else {
    # Process the result of the script execution
    $result = Receive-Job -Job $job
    # Process the result here
}

# Clean up the job
Remove-Job -Job $job
