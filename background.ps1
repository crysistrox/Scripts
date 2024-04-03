# Set the path to the image you want to use as the default desktop background
$ImagePath = "C:\background\3265869.png"

# Set the wallpaper style (0 for "Tile", 2 for "Center", 6 for "Stretch", 10 for "Fit", 0 for "Fill")
$WallpaperStyle = 2

# Set the default wallpaper for new users
$DefaultRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ThemeManager"
$DefaultRegName = "Wallpaper"
Set-ItemProperty -Path $DefaultRegPath -Name $DefaultRegName -Value $ImagePath

# Set the wallpaper style for new users
$DefaultWallpaperStyleRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
$DefaultWallpaperStyleRegName = "DesktopImagePath"
Set-ItemProperty -Path $DefaultWallpaperStyleRegPath -Name $DefaultWallpaperStyleRegName -Value $ImagePath

# Refresh the desktop to apply the changes
RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters
