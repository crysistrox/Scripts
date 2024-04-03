# Set the possible paths to the TeamViewer directory
$teamViewerPaths = @("C:\Program Files\TeamViewer", "C:\Program Files (x86)\TeamViewer")

# Flag to determine if TeamViewer directory is found
$teamViewerFound = $false

# Iterate through possible paths
foreach ($path in $teamViewerPaths) {
    if (Test-Path $path) {
        # Navigate to the TeamViewer directory
        Set-Location -Path $path
        
        # Run uninstall.exe with delete settings option
        Start-Process -FilePath "uninstall.exe" -ArgumentList "/S /DELETESETTINGS" -Wait
        Write-Host "TeamViewer Uninstallation completed."
        
        # Set flag to indicate that TeamViewer directory is found
        $teamViewerFound = $true
        break
    }
}

# Check if TeamViewer directory was not found
if (-not $teamViewerFound) {
    Write-Host "TeamViewer directory not found in the specified paths."
}
