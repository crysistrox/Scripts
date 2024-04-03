# Check if the PowerShellGet module is installed
if (!(Get-Module -ListAvailable -Name PowerShellGet)) {
    # Install the PowerShellGet module
    if (!(Test-Path "$env:ProgramFiles\PackageManagement\PackageManagement.psm1")) {
        # Install the NuGet provider if not already installed
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    }

    # Install the PowerShellGet module
    Install-Module -Name PowerShellGet -Force -AllowClobber -Scope AllUsers -SkipPublisherCheck
}