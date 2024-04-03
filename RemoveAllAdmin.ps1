# Get the name of the local administrator account
$localAdmin = "Administrator"

# Get all local users except the local administrator
$usersToExclude = Get-WmiObject -Class Win32_UserAccount | Where-Object { $_.Name -ne $localAdmin }

# Get the Administrators group
$administratorsGroup = Get-LocalGroup -Name "Administrators"

# Remove all users (except local administrator) from the Administrators group
foreach ($user in $usersToExclude) {
    $username = $user.Name
    if ($username -ne $localAdmin) {
        Remove-LocalGroupMember -Group $administratorsGroup.Name -Member $username -ErrorAction SilentlyContinue
    }
}
