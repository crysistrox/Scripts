# PowerShell code starts here
$notepadPlusPlusInstalled = winget list | Select-String -Pattern "Notepad\+\+"

if (-not $notepadPlusPlusInstalled) {
    # Install Notepad++ using winget
    winget install Notepad++
}

# Run Notepad++ as the logged-in local user
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Start-Process "notepad++.exe" -Wait -Credential $currentUser
