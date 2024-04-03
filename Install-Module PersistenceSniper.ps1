$timeout = New-TimeSpan -Minutes 60  # Set the timeout to 60 minutes
$timeoutSeconds = $timeout.TotalSeconds
$startTime = Get-Date

# Specify the username and password
$username = "mcooperadmin"
$password = ConvertTo-SecureString "V3nom0908#" -AsPlainText -Force

# Define the path for the log file on the desktop
$logFilePath = "C:\Users\mcooper\OneDrive - Bankers Healthcare Group Inc\Desktop", "ScriptLog.txt")

# Function to write log entries
function Write-LogEntry {
    param (
        [string]$logMessage
    )

    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $logMessage"
    $logEntry | Out-File -Append -FilePath $logFilePath
}


Install-Module -Name PersistenceSniper -Force -AllowClobber -Scope AllUsers -SkipPublisherCheck -Verbose *> $null