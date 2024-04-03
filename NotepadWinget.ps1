# Check if Notepad++ is already installed
$notepadPlusPlusInstalled = Get-Command -ErrorAction SilentlyContinue -Name notepad++.exe

if (-not $notepadPlusPlusInstalled) {
    # Check if winget is installed
    $wingetInstalled = Get-Command -Name winget -ErrorAction SilentlyContinue

    if (-not $wingetInstalled) {
        # Download and install winget
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://aka.ms/install-winget'))
        # Wait for a moment to let winget installation complete
        Start-Sleep -Seconds 10
    }

    # Install Notepad++ using winget without prompts
    Start-Process -NoNewWindow -Wait -FilePath "winget" -ArgumentList "install Notepad++"
}

