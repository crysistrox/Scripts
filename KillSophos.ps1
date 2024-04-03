# Kill Sophos-related processes
Get-Process -Name 'Sophos*' | ForEach-Object { Stop-Process -Id $_.Id -Force }

# Delete the Sophos folder
$SophosFolderPath = "C:\Program Files\Sophos"
if (Test-Path -Path $SophosFolderPath) {
    Remove-Item -Path $SophosFolderPath -Recurse -Force
    Write-Host "Sophos folder has been deleted."
} else {
    Write-Host "Sophos folder not found."
}

# Remove registry keys
$RegistryKeys = @(
    "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Sophos",
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Application\Sophos Management Communications System",
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Application\Sophos System Protection"
)

foreach ($key in $RegistryKeys) {
    if (Test-Path -Path $key) {
        Remove-Item -Path $key -Recurse -Force
        Write-Host "Registry key $key has been removed."
    } else {
        Write-Host "Registry key $key not found."
    }
}

# Empty the Recycle Bin
$RecycleBin = [System.IO.Directory]::GetDirectories([System.IO.Path]::Combine($env:USERPROFILE, "AppData\Local\Microsoft\Windows\Explorer"))
$RecycleBin | ForEach-Object {
    $Shell = New-Object -ComObject Shell.Application
    $RecycleBinFolder = $Shell.NameSpace($_)
    $RecycleBinItems = $RecycleBinFolder.Items()
    $RecycleBinItems.InvokeVerb("Empty Recycle Bin")
}

Write-Host "Recycle Bin has been emptied."
