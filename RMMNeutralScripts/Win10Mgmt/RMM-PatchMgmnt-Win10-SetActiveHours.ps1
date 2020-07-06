<#
=================================================================================
Filename:           RMM-PatchMgmnt-Win10-SetActiveHours.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-04-22
=================================================================================
#>

Write-host "UPSTREAM: Setting Active Hours to 06:00-22:00 in the registry."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name ActiveHoursStart -Value 6 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name ActiveHoursEnd -Value 20 -Force
