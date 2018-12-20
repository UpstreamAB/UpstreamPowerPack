# Script name: RMM-PatchMgmnt-Windows10-DeferFeatureUpgrades.ps1
# Script type: PowerShell
# Script description: Deploy Webroot silently with associated Webroot MSP site key
# Dependencies: Windows 10
# Script maintainer: powerpack@upstream.se
# https://www.upstream.com/powerpack

Write-host "UPSTREAM: Script name: RMM-PatchMgmnt-Windows10-DeferFeatureUpgrades.ps1"
Write-host "UPSTREAM: Setting a 365 days waiting period for any new Windows 10 version upgrade."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name DeferFeatureUpdatesPeriodInDays -Value 365 -PassThru
Write-host "UPSTREAM: Defer Feature Upgrades: End of PowerShell script: Evaluate the console output."
