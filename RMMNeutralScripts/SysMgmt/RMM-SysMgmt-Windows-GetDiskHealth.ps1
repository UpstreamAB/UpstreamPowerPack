# Script name: RMM-SysMgmt-Windows-DiskHealth.ps1
# Script type: Powershell
# Script description: .
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------
$DiskHealth = Get-PhysicalDIsk HealthStatus
Write-Output $DiskHealth
