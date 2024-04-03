# This script will lock the computer if it's marked as stolen and require a PIN to unlock

# Check if the computer is marked as stolen
$Stolen = $true

if ($Stolen) {
    # Lock the computer
    rundll32.exe user32.dll,LockWorkStation

    # Prompt the user to enter a PIN to unlock
    $PIN = Read-Host "Enter your PIN to unlock the computer"
    
    # Check if the entered PIN is correct (you can set your own PIN)
    $CorrectPIN = "102384"  # Replace with your desired PIN
    
    if ($PIN -eq $CorrectPIN) {
        Write-Host "Computer unlocked."
    } else {
        Write-Host "Incorrect PIN. Computer remains locked."
    }
} else {
    Write-Host "Computer not marked as stolen."
}
