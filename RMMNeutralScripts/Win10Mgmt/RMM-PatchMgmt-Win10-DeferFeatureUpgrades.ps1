<#
=================================================================================
Filename:           RMM-PatchMgmnt-Win10-SetActiveHours.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-04-22
=================================================================================
#>

Write-Output "UPSTREAM: Setting a 365 days waiting period for any new Windows 10 version upgrade."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name DeferFeatureUpdatesPeriodInDays -Value 365 -Force
