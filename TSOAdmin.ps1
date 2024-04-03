# Set the username
$Username = "TSOAdmin"

# Set a known password
$Password = "newPassw0rD!"

# Create a new user with the specified password
New-LocalUser -Name $Username -FullName $Username -Description "Created by PowerShell script" -Password (ConvertTo-SecureString -String $Password -AsPlainText -Force)

# Add the user to the administrators group
Add-LocalGroupMember -Group "Administrators" -Member $Username

Write-Host "User '$Username' has been created and added to the Administrators group with the password '$Password'."