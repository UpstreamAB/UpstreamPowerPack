# Script name: RMM-PatchMgmnt-Windows10-SetActiveHours.ps1
# Script type: PowerShell
# Script description: Deploy Webroot silently with associated Webroot MSP site key
# Dependencies: Windows 10
# Script maintainer: powerpack@upstream.se
# https://www.upstream.com/powerpack

Write-host "UPSTREAM: Script name: RMM-PatchMgmnt-Windows10-SetActiveHours.ps1"
Write-host "UPSTREAM: Setting Active Hours to 06:00-22:00 in the registry."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name ActiveHoursStart -Value 7 -PassThru
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name ActiveHoursEnd -Value 18 -PassThru
Write-host "UPSTREAM: Deploy Webroot: End of PowerShell script: Evaluate the console output."
