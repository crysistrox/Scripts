# Specify the extension ID you want to add to the list
$extensionId = "gcfjbjldfomnopnpdjajjfpldkkdmmoi"

# Get the current list from the registry
$currentList = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" -Name 3).3

# Check if the current list is empty or doesn't exist
if (-not $currentList) {
    $currentList = ""
}

# Check if the extension ID is already in the list
if ($currentList -notlike "*$extensionId*") {
    # Add the extension ID to the list
    if ($currentList -ne "") {
        $newList = "$currentList,$extensionId"
    } else {
        $newList = $extensionId
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" -Name 3 -Value $newList
    Write-Host "Extension ID $extensionId added to the list."
} else {
    Write-Host "Extension ID $extensionId is already in the list."
}
