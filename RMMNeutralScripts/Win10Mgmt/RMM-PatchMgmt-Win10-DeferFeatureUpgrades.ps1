# Script name: RMM-PatchMgmt-Win10-DeferFeatureUpgrades.ps1
# Script type: PowerShell
# Script description: Setting a 365 days waiting period for any new Windows 10 release (like for example Windows 10 October release 2018)
# Dependencies: Windows 10
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

Write-Output "UPSTREAM: Setting a 365 days waiting period for any new Windows 10 version upgrade."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name DeferFeatureUpdatesPeriodInDays -Value 365 -PassThru
