# Define the specific users and domain groups
$specificUsers = @("TSOAdmin", "Administrator")
$allowedGroups = @("BHG\Domain Admins", "BHG\Local_Admins", "BHG\Local_Admins_Workstations")

# Get all members of the local administrators group
$localAdmins = (net localgroup Administrators) | ForEach-Object {
    $_ -replace '^The .+ contains the following members:', '' -replace '  ', ','
}

# Remove local admin access for unauthorized users
foreach ($user in $localAdmins) {
    if ($user -ne "" -and $user -notin $allowedGroups -and $user -notin $specificUsers -and $user -notmatch '^BUILTIN\\') {
        # Check if the username is not empty before attempting to remove
        net localgroup Administrators $user /delete
        Write-Host "Removed $($user) from local administrators group."
    }
}

Write-Host "Local administrator access has been removed for unauthorized users."

# Force Group Policy update
Start-Process -FilePath "C:\Windows\System32\gpupdate.exe" -ArgumentList "/force" -Wait

Write-Host "Group Policy updates have been forced on the local machine."

#written by: Meshach Cooper