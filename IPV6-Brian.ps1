# Check if the script is running with administrative privileges
$isAdmin = ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

 

if (-not $isAdmin) {
    Write-Host "Please run this script as an administrator."
    Exit
}

 

# Disable IPv6 on all network adapters
Get-NetAdapter | ForEach-Object {
    Disable-NetAdapterBinding -Name $_.Name -ComponentID "ms_tcpip6"
}

 

Write-Host "IPv6 has been disabled for all network adapters."