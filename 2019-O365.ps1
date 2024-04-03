# Define the path to the Office 2019 uninstallation executable
$office2019UninstallPath = "C:\Program Files\Microsoft Office 15\ClientX64\OfficeClickToRun.exe"

# Define the XML configuration for Office 365 installation
$configurationXml = @"
<Configuration>
    <Add OfficeClientEdition="64" Channel="Broad">
        <Product ID="O365ProPlusRetail">
            <Language ID="en-us" />
        </Product>
    </Add>
    <RemoveMSI All="True" />
    <Display Level="None" AcceptEULA="True" />
</Configuration>
"@

# Check if Office 2019 is installed
if (Test-Path $office2019UninstallPath) {
    Write-Host "Office 2019 is installed. Proceeding with upgrade..."

    # Uninstall Office 2019
    Start-Process -FilePath $office2019UninstallPath -ArgumentList "/uninstall", "/all", "/quiet" -Wait

    # Start the Office 365 installation
    Write-Host "Starting Office 365 upgrade..."

    $odtPath = Join-Path $env:TEMP "ODT"
    
    # Remove existing ODT directory if it exists
    if (Test-Path $odtPath) {
        Remove-Item -Path $odtPath -Recurse -Force
    }
    
    # Create a new ODT directory
    New-Item -Path $odtPath -ItemType Directory | Out-Null
    Set-Content -Path "$odtPath\configuration.xml" -Value $configurationXml

    $office365SetupUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_16529-20182.exe"
    $office365SetupPath = "$odtPath\setup.exe"

    # Download the Office Deployment Tool (ODT)
    (New-Object System.Net.WebClient).DownloadFile($office365SetupUrl, $office365SetupPath)

    # Start the Office 365 installation using ODT
    Start-Process -FilePath $office365SetupPath -ArgumentList "/configure $odtPath\configuration.xml" -Wait

    Write-Host "Office 365 upgrade completed successfully."
}
else {
    Write-Host "Office 2019 is not installed on this machine."
}
