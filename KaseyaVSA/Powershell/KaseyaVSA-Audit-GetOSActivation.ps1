# Script name: KaseyaVSA-Audit-GetOSActivation.ps1
# Related Kaseya Agent Procedure: "Audit - Windows - Is Windows Activated"
# Script description: Audit if the Windows OS is activated with a valid license.
# Upload this Powershell script to your Kaseya Agent Procedures folder "VSASharedFiles\UpstreamPowerPack\Powershell".
# Supported OS: Windows OS.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

Get-CimInstance -ClassName SoftwareLicensingProduct | Where{$_.PartialProductKey -and $_.Name -Like "*Windows(R)*"} | Select -Expand LicenseStatus
