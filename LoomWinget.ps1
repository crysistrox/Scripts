# Function to install Loom using winget
function Install-Loom {
    # Check if winget is available
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "Error: winget is not available on this system."
        return
    }

    # Install Loom
    Write-Host "Installing Loom..."
    winget install -e --id Loom.Loom

    # Check for installation success
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Loom has been successfully installed."
    } else {
        Write-Host "Error: Failed to install Loom."
    }
}

# Call the function to install Loom
Install-Loom
