# Function to get user confirmation
function Get-Confirmation {
    param (
        [string]$message
    )

    $response = Read-Host -Prompt "$message (Y/N)"
    return ($response -eq 'Y' -or $response -eq 'y')
}

# Prompt for credentials
$credential = Get-Credential -Message "Enter your credentials"

# Check for running processes containing the name "Tanium"
$taniumProcesses = Get-Process -Name "*Tanium*" -ErrorAction SilentlyContinue

# If Tanium processes are running, ask for confirmation to terminate them
if ($taniumProcesses.Count -gt 0) {
    $confirmationMessage = "Processes with the name 'Tanium' are currently running. Do you want to terminate them?"
    if (Get-Confirmation -message $confirmationMessage) {
        # Terminate Tanium processes
        $taniumProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force }
        Write-Host "Tanium processes terminated successfully."
    } else {
        Write-Host "Operation canceled. Please terminate Tanium processes manually and run the script again."
        exit
    }
}

# Specify directories to be removed
$dirsToRemove = @(
    "C:\Program Files (x86)\Tanium\.certs",
    "C:\Program Files (x86)\Tanium\Tanium End User Notification Tools",
    "C:\Program Files (x86)\Tanium\Tanium Client"
)

# Get confirmation before removing specified directories
foreach ($dirToRemove in $dirsToRemove) {
    $confirmationMessage = "Are you sure you want to remove $dirToRemove?"
    if (Get-Confirmation -message $confirmationMessage) {
        Remove-Item -Path $dirToRemove -Recurse -Force
        Write-Host "$dirToRemove removed successfully."
    } else {
        Write-Host "Operation canceled for $dirToRemove."
        exit
    }
}

# Silent uninstallation of Tanium Client
Start-Process -FilePath "C:\Program Files (x86)\Tanium\Tanium Client\uninst.exe" -ArgumentList "/S" -Credential $credential -Wait

# Wait for the uninstaller process to complete
$uninstallerProcess = Get-Process -Name "uninst"
$uninstallerProcess.WaitForExit()

# Remove Tanium Client installation directory
$installDir = "C:\Program Files (x86)\Tanium\Tanium Client"
Remove-Item -Path $installDir -Recurse -Force

# Remove Tanium parent directory if empty
$parentDir2 = "C:\Program Files (x86)\Tanium\Tanium End User Notification Tools"
Remove-Item -Path $parentDir2 -Recurse -Force

# Remove Tanium parent directory if empty
$parentDir3 = "C:\Program Files (x86)\Tanium\.certs"
Remove-Item -Path $parentDir3 -Recurse -Force

# Remove Tanium main directory if empty
$parentDir4 = "C:\Program Files (x86)\Tanium"
Remove-Item -Path $parentDir4 -Recurse -Force
