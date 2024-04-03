# Specify the username and password
$Username = "Mcooper"
$Password = ConvertTo-SecureString "V3nom0908#" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

# Check if the NuGet provider is installed
if (-not (Get-PackageSource | Where-Object { $_.Name -eq 'nuget.org' })) {
    Start-Process powershell.exe -Credential $Credential -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"Install-PackageProvider -Name NuGet -Force`""
}

# Specify the NuGet package name
$packageName = 'PersistenceSniper'

# Check if the package is already installed
if (-not (Get-Package -Name $packageName -ErrorAction SilentlyContinue)) {
    Start-Process powershell.exe -Credential $Credential -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"Install-Package -Name $packageName -Force`""
}


