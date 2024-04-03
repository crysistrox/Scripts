$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$Criteria = "IsInstalled=0 and Type='Software'"
$SearchResult = $Searcher.Search($Criteria)

if ($SearchResult.Updates.Count -eq 0) {
    Write-Host "No updates are available for installation."
} else {
    $Installer = New-Object -ComObject Microsoft.Update.Installer
    $Installer.Updates = $SearchResult.Updates
    $InstallationResult = $Installer.Install()

    if ($InstallationResult.HResult -eq 0) {
        Write-Host "Updates were successfully installed."
    } else {
        Write-Host "Failed to install updates. HResult: $($InstallationResult.HResult)"
    }
}
