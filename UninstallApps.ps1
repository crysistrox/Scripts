# Prompt the user for the application name to uninstall
$applicationName = Read-Host "Enter the name of the application to uninstall"

# Check if the application is installed
if (Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name='$applicationName'" -ErrorAction SilentlyContinue) {
    # Prompt for admin credentials
    $adminUsername = Read-Host "Enter the username of a domain administrator account"
    $adminPassword = Read-Host -AsSecureString "Enter the password for $adminUsername"

    # Uninstall the application silently
    $uninstallCommand = "msiexec.exe /x $((Get-WmiObject -Query ""SELECT * FROM Win32_Product WHERE Name='$applicationName'"").IdentifyingNumber) /qn"
    
    # Display a basic progress bar
    $progress = 0
    $totalSteps = 10

    Write-Progress -Activity "Uninstalling $applicationName" -Status "Progress" -PercentComplete $progress

    # Simulate progress
    for ($i = 1; $i -le $totalSteps; $i++) {
        Start-Sleep -Seconds 1
        $progress = ($i / $totalSteps) * 100
        Write-Progress -Activity "Uninstalling $applicationName" -Status "Progress" -PercentComplete $progress
    }

    # Install the PSCX module if not already installed
    if (-not (Get-Module -ListAvailable -Name Pscx)) {
        Install-Module -Name Pscx -Force -AllowClobber -Scope CurrentUser
        Import-Module Pscx
    }

    # Execute the uninstallation command with admin credentials using Start-Process from PSCX module
    $secureAdminPassword = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential -ArgumentList @($adminUsername, $secureAdminPassword)

    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $((Get-WmiObject -Query ""SELECT * FROM Win32_Product WHERE Name='$applicationName'"").IdentifyingNumber) /qn" -Credential $credential -Wait

    # Completed progress bar
    Write-Progress -Activity "Uninstalling $applicationName" -Status "Completed" -Completed
    Write-Host "$applicationName has been uninstalled silently."
} else {
    Write-Host "$applicationName is not installed."
}
