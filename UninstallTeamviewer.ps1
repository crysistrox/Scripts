# Define the display name of TeamViewer
$teamViewerDisplayName = "TeamViewer"

# Get a list of installed TeamViewer instances
$teamViewerInstances = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%$teamViewerDisplayName%'" | Select-Object Name, Version

# Check if TeamViewer is installed
if ($teamViewerInstances) {
    foreach ($instance in $teamViewerInstances) {
        $teamViewerName = $instance.Name
        $teamViewerVersion = $instance.Version

        Write-Output "Uninstalling $teamViewerName version $teamViewerVersion"

        # Uninstall TeamViewer silently
        $uninstallCommand = "msiexec.exe /x $($instance.IdentifyingNumber) /quiet"
        Start-Process -FilePath $uninstallCommand -Wait
    }

    Write-Output "TeamViewer uninstallation complete."
} else {
    Write-Output "TeamViewer is not installed on this computer."
}
