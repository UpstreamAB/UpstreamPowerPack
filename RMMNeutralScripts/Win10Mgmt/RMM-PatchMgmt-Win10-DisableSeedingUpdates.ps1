<#
=================================================================================
Filename:           RMM-PatchMgmt-Win10-DisableSeedingUpdates.ps1
Kaseya Procedure:   Custom Field - Audit - Windows 10 - Get Azure AD Tenant And User
Support type:       Upstream Premium Power Pack
Support:            Upstream AB, premium@upstream.se Last updated 2020-04-22
=================================================================================
#>

Write-Output "UPSTREAM: Disbles the seeding feature in Windows 10 to share downloaded patches with machines nearby."
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name DODownloadMode -Value 0 -Force
