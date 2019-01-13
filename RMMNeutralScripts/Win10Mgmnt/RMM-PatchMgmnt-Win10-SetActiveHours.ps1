# Script name: RMM-PatchMgmnt-Win10-SetActiveHours.ps1
# Script type: PowerShell
# Script description: Apply active working hours between 06:00-20:00 where Windows wont bother you with updates.
# Dependencies: Windows 10
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

Write-host "UPSTREAM: Setting Active Hours to 06:00-22:00 in the registry."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name ActiveHoursStart -Value 6 -PassThru
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name ActiveHoursEnd -Value 20 -PassThru
