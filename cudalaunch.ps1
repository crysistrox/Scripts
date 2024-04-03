# Get the current script directory
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Specify the path to the appx package
$appxPackagePath = Join-Path $scriptDirectory "cudalaunch.appx"

# Install the appx package silently
Add-AppxPackage -Path $appxPackagePath -ForceApplicationShutdown -Register
