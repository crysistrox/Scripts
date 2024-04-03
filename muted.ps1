# Set the duration for the script to run (in seconds)
$durationInSeconds = 5 * 60 * 60  # 5 hours

# Function to mute the audio on the local machine
function Mute-Audio {
    Set-SoundVolume -Volume 0  # Set volume to 0 to mute
}

# Start time of the script
$startTime = Get-Date

# Loop until the specified duration is reached
while ((Get-Date) -lt ($startTime.AddSeconds($durationInSeconds))) {
    # Mute audio
    Mute-Audio

    # Sleep for a random interval (between 1 and 30 minutes)
    Start-Sleep -Seconds (Get-Random -Minimum 60 -Maximum 1800)
}

# Optionally, unmute audio at the end of the script
# Uncomment the following line if you want to unmute at the end
# Set-SoundVolume -Volume 50  # Adjust volume level as needed
