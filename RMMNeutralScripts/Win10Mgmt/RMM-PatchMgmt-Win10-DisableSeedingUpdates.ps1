# Script name: RMM-PatchMgmt-Win10-DisableSeedingUpdates.ps1
# Script type: PowerShell
# Script description: Disbles the seeding feature in Windows 10 to share downloaded patches with machines nearby.
# Dependencies: Windows 10
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack 

Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name DODownloadMode -Value 0 -PassThru
