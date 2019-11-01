# Script name: Monitor-AddServicesToPulsewayMonitoring.ps1
# Script type: Powershell
# Script description: Register Auto started Windows Services to Pulseway Services monitoring excempt for a "notmach" black list.
# Dependencies: Windows Server
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

# Find all Windows Services set to Start Mode Auto but ignore a fixed blacklist by service name. Evaluate the current blacklist and decide what you want to add/remove.
$Services = Get-WmiObject win32_service -Filter "StartMode = 'Auto'" | Where-Object Name -notmatch 'sppsvc|gupdate|BITS|RemoteRegistry|WbioSrvc'
Set-ItemProperty -Path "HKLM:\Software\MMSOFT Design\PC Monitor\Services" -Name "Count" -Value $Services.Count.ToString()

# Add each monitored Windows Service to the local registry of the monitored machine.
"UPSTREAM: Adding Windows Services to Pulseway monitoring:" 
$Count = 0;
foreach ($Service in $Services)
{
    Write-Output $Service.Name
    Set-ItemProperty -Path "HKLM:\Software\MMSOFT Design\PC Monitor\Services" -Name ("Service" + $count++) -Value $Service.Name
}
