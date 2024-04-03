# Define the old and new file paths
$oldFilePath = "C:\Program Files\Palo Alto Networks\DEM\agent.db"
$newFilePath = "C:\Program Files\Palo Alto Networks\DEM\agent.db.old"

# Rename the file
Rename-Item -Path $oldFilePath -NewName $newFilePath
