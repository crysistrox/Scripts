
#vars
$PortalAddress = 'bhgvpn.bhg-inc.com'
$OldPortals = @('rm.bhg-inc.com' , 'rm1.bhg-inc.com' , 'rm2.bhg-inc.com' , 'rm3.bhg-inc.com' )

#Get current portal
$pansetup = Get-ItemProperty -path "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup" -Name 'Portal'
$pansetup = $pansetup.Portal

#Write-Host "Changing install portal address $pansetup to $PortalAddress"

#stop global protect
Stop-Service PanGPS
#set portal adres for new installations
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
 
    #####################################################################
    # This is where you can read/modify a users portion of the registry 
 
    "{0}" -f $($item.Username) | Write-Output
    Set-Itemproperty -path "registry::HKEY_USERS\$($Item.SID)\Software\Palo Alto Networks\GlobalProtect\Settings" -Name 'LastUrl' -value $PortalAddress
    
    Foreach ($Oldportal in $Oldportals) { 
        Remove-Item -path "registry::HKEY_USERS\$($Item.SID)\Software\Palo Alto Networks\GlobalProtect\Settings\$OldPortal" -Recurse   
    }
    #####################################################################
 
    # Unload ntuser.dat        
    IF ($item.SID -in $UnloadedHives.SID) {
        ### Garbage collection and closing of ntuser.dat ###
        [gc]::Collect()
        reg unload HKU\$($Item.SID) | Out-Null
    }
}
#start global protectc
Start-Service PanGPS
