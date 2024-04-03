# Variables
$NewPortalAddress = 'bhgvpn.bhg-inc.com'
$AllowedPortals = @('bhgvpn.bhg-inc.com', 'bhgvpn.gpcloudservice.com' , 'rmsny4.bhg-inc.com')
$OldPortals = @('rm.bhg-inc.com', 'rm1.bhg-inc.com', 'rm2.bhg-inc.com', 'rmsny.bhg-inc.com')

# Get Current Portal
$pansetup = Get-ItemProperty -path "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup" -Name 'Portal'
$currentPortal = $pansetup.Portal

# Stop GlobalProtect Service
Write-Host "Stopping GP Agent Services..."
Stop-Service PanGPS

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

# Check Current Active Portal and Update it if they are were using a legacy portal name.
if ($currentPortal -notin $AllowedPortals) {
  Write-Host "Your current active portal address is set to $currentPortal."
  Write-Host "You appear to be using the legacy RM/RM1/RM2 VPN Nodes. Updating your portal to bhgvpn.bhg-inc.com and removing the old entry."
  # Set portal address for new installations
  Set-Itemproperty -path "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup" -Name 'Portal' -value $NewPortalAddress
  } else {
    Write-Host "The current portal is one of the allowed portals. No changes will be made to the active portal configuration."
}

# Check the remaining registry vlues for full portal list, add bhgvpn.bhg-inc.com regardless if it is there or not, and remove RM/RM1/RM2.
Foreach ($item in $ProfileList) {
    # Load User ntuser.dat if it's not already loaded
    Write-Host "Loading ntuser.dat file if it is not already loaded."
    IF ($item.SID -in $UnloadedHives.SID) {
        reg load HKU\$($Item.SID) $($Item.UserHive) | Out-Null
    }

    # This is where you can read/modify a users portion of the registry 
    "{0}" -f $($item.Username) | Write-Output
    Set-Itemproperty -path "registry::HKEY_USERS\$($Item.SID)\Software\Palo Alto Networks\GlobalProtect\Settings" -Name 'LastUrl' -value $NewPortalAddress
    Write-Host "Adding $NewPortalAddress to registry values."

    Foreach ($Oldportal in $Oldportals) { 
    Write-Host "Removing $Oldportal."
    Remove-Item -path "registry::HKEY_USERS\$($Item.SID)\Software\Palo Alto Networks\GlobalProtect\Settings\$OldPortal" -Recurse   
    }

    # Unload ntuser.dat
    Write-Host "Unoading ntuser.dat file if it exists."
    IF ($item.SID -in $UnloadedHives.SID) {
        ### Garbage collection and closing of ntuser.dat ###
        [gc]::Collect()
        reg unload HKU\$($Item.SID) | Out-Null
    }
}

# Start GlobalProtect Service
Write-Host "Starting GP Agent Services..."
Start-Service PanGPS

# Start the GlobalProtect application
$GlobalProtectPath = 'C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPA.exe'
Start-Process -FilePath $GlobalProtectPath