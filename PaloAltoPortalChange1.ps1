# Check for input
if (!$args[0]) {
    Write-Host "Invalid argument. usage: change-portal.ps1 <new portal>"
    exit
}

# Vars
$PortalAddress = $args[0]
$OldPortals = @('rm.bhg-inc.com')

# Stop GlobalProtect Service
Stop-Service PanGPS

# Set New Portal Address in Registry
Set-Itemproperty -path "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup" -Name 'Portal' -value $PortalAddress

# Regex pattern for SIDs
$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'

# Get Username, SID, and location of ntuser.dat for all users
$ProfileList = gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $PatternSID} | 
    Select  @{name="SID";expression={$_.PSChildName}}, 
            @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}}, 
            @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}

# Get all user SIDs found in HKEY_USERS (ntuder.dat files that are loaded)
$LoadedHives = gci Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} | Select @{name="SID";expression={$_.PSChildName}}

# Get all users that are not currently logged
$UnloadedHives = Compare-Object $ProfileList.SID $LoadedHives.SID | Select @{name="SID";expression={$_.InputObject}}, UserHive, Username

# Loop through each profile on the machine
Foreach ($item in $ProfileList) {
    # Load User ntuser.dat if it's not already loaded
    IF ($item.SID -in $UnloadedHives.SID) {
        reg load HKU\$($Item.SID) $($Item.UserHive) | Out-Null
    }

    # This is where you can read/modify a user's portion of the registry
    "{0}" -f $($item.Username) | Write-Output

    # Update LastUrl with the new portal address
    Set-Itemproperty -path "registry::HKEY_USERS\$($Item.SID)\Software\Palo Alto Networks\GlobalProtect\Settings" -Name 'LastUrl' -value $PortalAddress

    # Remove old portal address from the settings
    Foreach ($OldPortal in $OldPortals) {
        Remove-Item -path "registry::HKEY_USERS\$($Item.SID)\Software\Palo Alto Networks\GlobalProtect\Settings\$OldPortal" -Recurse -ErrorAction SilentlyContinue
    }

    # Unload ntuser.dat
    IF ($item.SID -in $UnloadedHives.SID) {
        [gc]::Collect()
        reg unload HKU\$($Item.SID) | Out-Null
    }
}

# Start GlobalProtect Service
Start-Service PanGPS
