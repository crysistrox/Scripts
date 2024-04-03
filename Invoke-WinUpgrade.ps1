
<#
.Synopsis
    Windows 10 In Place Upgrade
.DESCRIPTION
    Tanium Deploy wrapper script for a Microsoft Windows 10 In Place Upgrade - Part 3 - Actual Upgrade
.NOTES
    Copyright Tanium, All rights Reserved
    Add this script *AND* a WIndows 10 Deployment Media ( Extracted ISO, ZIP, or ISO ) to the Deploy Package
    Ensure client has Anti-Virus Exceptions for c:\deploy
.LINK
    https://tanium.com/products/deploy/
    https://microsoft.com/Deployment
.Parameter Path
    Target Directory, for extracted WIM file
.Parameter RegStatus
    Registry Key for Status Messages
.Paramater RemainingArgs
    Any additional arguments are passed in directly to Windows 10 Setup.exe
#>

[cmdletbinding()]
param(
    $path = 'c:\deploy\Tanium\OS',
    $RegKey = '%TANIUMROOT%\Tanium Client\OSD',

    [parameter(position=1, ValueFromRemainingArguments=$true)]
    [string[]] $RemainingArgs

)

try { Start-Transcript -path $env:temp\Win10IPU_Upgrade.txt -Append } catch {}

#region Initialize and Cleanup

if ( [IntPtr]::Size -ne 8  ) {
    $TaniumRegKey = $regKey.Replace('%TANIUMROOT%','HKLM:\Software\tanium' )
}
else {
    $TaniumRegKey = $regKey.Replace('%TANIUMROOT%','HKLM:\Software\WOW6432Node\tanium' )
}

$SetupArgs = @(
    '/auto', 'Upgrade'
    '/NoReboot'
    '/Quiet'
    '/DynamicUpdate', 'disable'
    '/ShowOOBE', 'none'
    '/Telemetry','disable'
    '/Uninstall','enable'
    '/Compat','IgnoreWarning'  # Ignore Warnings (not the hard stuff)

    # Other arguments that are INTRESTING, but unknown at this point.
    # '/BitLocker',  'ForceKeepActive'
    # '/DiagnosticPrompt', 'enable'
    # '/InstallLangPacks'. 'c:\foo'
    # '/MigrateDrivers', 'none'
    # '/ReflectDrivers', 'none'
    $RemainingArgs
)

#endregion

#region Auto fix for Enterprise SKU

if ( Get-WmiObject Win32_operatingSystem | Where-Object { $_.OperatingSystemSKU -eq 4 -and $_.Version -like '6.1.*' } ) {
    if ( $setupArgs -notmatch '/PKEY') {

        # In some instances when upgrading from Windows 7 Enterprise,
        #    Setup will default back to Pro, and fail setup.
        #    Forcing a key should help for Ent to Ent.
        #    Source: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys
        Write-Host "Force PKEY ugprade for Enterprise SKU"
        $SetupArgs += @( '/PKEY', "NPPR9-FWDCX-D2C8J-H872K-2YT43" )

    }
}

#endregion

#region Import Optional Components

if ( Test-Path $path\..\Drivers ) {

    Write-Host "Install Drivers on $Path\..\Drivers"
    $SetupArgs += @( '/InstallDrivers', "$Path\..\Drivers" )

}

if ( Test-Path $path\..\Languages ) {

    Write-Host "Install LanguagePakcs on $Path\..\Languages"
    $SetupArgs += @( '/InstallLangPacks', "$Path\..\Languages" )

}

if ( Test-Path $path\..\OEM\* ) {

    Write-Host "Install extra conent from  on $Path\..\OEM"
    $SetupArgs += @( '/m', "$Path\..\OEM" )

}

#endregion

#region PreFlight Routines

# Verify Battery
# Other???

<#
    [PSCustomObject] @{
        filter = [PSCustomObject] @{
            field = 'wmi_query'
            value = 'root\wmi'
            operator = 'returns_results'
            secondValue = 'Select * from batterystatus where discharging=FALSE'
        }
    }
    [PSCustomObject] @{
        filter = [PSCustomObject] @{
            field = 'wmi_query'
            value = 'root\wmi'
            operator = 'returns_no_results'
            secondValue = 'Select * from batterystatus'
        }
    }
#>

#endregion

#region PowerCfg

# Get the current power plan
$OldPowerPlan = Get-WmiObject -Namespace 'root\cimv2\power' win32_powerplan -Filter 'isActive = "True"' |
    ForEach-Object { $_.__path } |
    Where-Object { $_ -match '{([0-9A-F\-]*)}?' } |
    ForEach-Object { $matches[1] }

#endregion

#region Prepare Pass and fail cleanup routines

@"

:: This script is executed when Windows In-Place Upgrade has Failed

@if not defined debug echo off

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    reg.exe add "HKLM\Software\Tanium\Tanium Client\OSD" /V Status /reg:32 /d "Setup FAILED" /F
) ELSE (
    reg.exe add "HKLM\Software\Tanium\Tanium Client\OSD" /V Status /d "Setup FAILED" /F
)

if exist c:\Deploy\Tanium\PostRollBack.ps1 (
    powershell.exe -executionPolicy BYPASS -command "Start-Transcript -path %temp%\Win10IPU_PostRollBack.txt -Append; c:\Deploy\Tanium\PostRollBack.ps1"
)

"@ | Out-File -Encoding ascii -FilePath "$Path\..\SetupRollback.cmd"
$SetupArgs +=  @( '/PostRollback', (resolve-path "$Path\..\SetupRollback.cmd").path )

@"

:: This script is executed when Windows In-Place Upgrade has passed

@if not defined debug echo off

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    reg.exe add "HKLM\Software\Tanium\Tanium Client" /V ActionLockFlag /reg:32 /d 0 /t REG_DWORD /F
    reg.exe add "HKLM\Software\Tanium\Tanium Client\OSD" /V Status /reg:32 /d "Setup Complete" /F
) ELSE (
    reg.exe add "HKLM\Software\Tanium\Tanium Client" /V ActionLockFlag /d 0 /t REG_DWORD /F
    reg.exe add "HKLM\Software\Tanium\Tanium Client\OSD" /V Status /d "Setup Complete" /F
)

:: Insure that the Tanium Client has started (in case of timeout during Setup)
net start "Tanium Client" >> %temp%\Win10IPU_PostOOBE.txt 2>&1

$( if ( $oldPowerPlan -ne '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' ) { "powercfg.exe /setactive $oldPowerPlan >> %temp%\Win10IPU_PostOOBE.txt" } )

if exist c:\Deploy\Tanium\PostOOBE.ps1 (
    powershell.exe -executionPolicy BYPASS -command "Start-Transcript -path %temp%\Win10IPU_PostOOBE.txt -Append; c:\Deploy\Tanium\PostOOBE.ps1"
)

"@ | Out-File -Encoding ascii -FilePath "$Path\..\SetupComplete.cmd"
$SetupArgs += @( '/PostOOBE', (resolve-path "$Path\..\SetupComplete.cmd").path )

#endregion

#region Start installation

Set-ItemProperty -Path (Split-Path $TaniumRegKey) -Name ActionLockFlag -Value 1  # Suspend Tanium Acitons
Set-ItemProperty -Path $TaniumRegKey -Name Status -Value 'Start Upgrade'

if ( $oldPowerPlan -ne '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' ) {
    write-verbose "change PowerPlan From: $OldPowerPlan to High Performance"
    powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | out-string | Write-Verbose
}

start-process $Path\Setup.exe -argumentlist $SetupArgs

Start-Sleep 5
$commandLine = Get-WmiObject Win32_Process -Filter "name Like 'Setup%'" | Select-Object CommandLine
while ($commandLine){
	start-sleep 5
	$commandLine = Get-WmiObject Win32_Process -Filter "name Like 'Setup%'" | Select-Object CommandLine
	foreach ($_command in $commandLine){
		if ($_command -like "C:\Deploy*"){
			continue
		}
		break
	}
}

Set-ItemProperty -Path $TaniumRegKey -Name Status -Value 'Upgrade In Progress' -Force

Set-ItemProperty -Path (Split-Path $TaniumRegKey) -Name ActionLockFlag -Value 0  # Resume Tanium Actions

try { Stop-Transcript } catch {}

exit 0