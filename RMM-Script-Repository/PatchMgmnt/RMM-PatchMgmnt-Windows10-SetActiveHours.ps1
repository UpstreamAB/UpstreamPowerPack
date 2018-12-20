# Script name: RMM-PatchMgmnt-Windows10-SetActiveHours.
# Script type: PowerShell.
# Script description: Deploy Webroot silently with associated Webroot MSP site key.
# Dependencies: Webroot site key to be added as $WebrootKey variable.
# Script maintainer: powerpack@upstream.se
# https://www.upstream.com/powerpack

Write-host "UPSTREAM: Set Active Hours: Setting Active Hours to 06:00-22:00 in the registry.
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name ActiveHoursStart -Value 6 -PassThru
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name ActiveHoursEnd -Value 22 -PassThru
Write-host "UPSTREAM: Deploy Webroot: End of PowerShell script: Evaluate the console output.
