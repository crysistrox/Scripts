# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an administrator."
    Exit
}

# Disable IPv6 for network adapters
$adapters = Get-NetAdapter

foreach ($adapter in $adapters) {
    # Check if IPv6 is enabled for the adapter
    $ipv6Enabled = (Get-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6).Enabled

    if ($ipv6Enabled) {
        Write-Host "Disabling IPv6 for $($adapter.Name)"
        Set-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6 -Enabled $false
    }
}

# Verify the changes
$adaptersWithIPv6 = Get-NetAdapterBinding | Where-Object {$_.ComponentID -eq "ms_tcpip6" -and $_.Enabled -eq $true}

if ($adaptersWithIPv6.Count -eq 0) {
    Write-Host "IPv6 has been successfully disabled for network adapters."
} else {
    Write-Host "IPv6 could not be disabled for some network adapters."
}
