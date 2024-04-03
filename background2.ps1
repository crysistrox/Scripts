# Set the path to the image you want to use as the desktop background
$ImagePath = "C:\background\3265869.png"

# Set the wallpaper style (0 for "Tile", 2 for "Center", 6 for "Stretch", 10 for "Fit", 0 for "Fill")
$WallpaperStyle = 0

# Set the SPI_SETDESKWALLPAPER flag for SystemParametersInfo
$SPI_SETDESKWALLPAPER = 0x0014

# Call SystemParametersInfo to set the desktop background
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Wallpaper {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@

# Update the desktop background
[Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $ImagePath, 3)

# Set the wallpaper style in the registry
$RegPath = "HKCU:\Control Panel\Desktop"
$RegName = "WallpaperStyle"
Set-ItemProperty -Path $RegPath -Name WallpaperStyle -Value $WallpaperStyle
