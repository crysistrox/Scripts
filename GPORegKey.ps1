# Set the registry key HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications\ConfigureChatAutoInstall to 0
$regPathAutoInstall = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications"
$regNameAutoInstall = "ConfigureChatAutoInstall"
$regValueAutoInstall = 0

# Set the registry key HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat\ChatIcon to 3
$regPathChatIcon = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
$regNameChatIcon = "ChatIcon"
$regValueChatIcon = 3

# Set the DWORD values
Set-ItemProperty -Path $regPathAutoInstall -Name $regNameAutoInstall -Value $regValueAutoInstall -ErrorAction SilentlyContinue
Set-ItemProperty -Path $regPathChatIcon -Name $regNameChatIcon -Value $regValueChatIcon -ErrorAction SilentlyContinue