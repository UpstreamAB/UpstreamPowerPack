# Script name: KaseyaVSA-Audit-GetCurrentFreeDiskOnC.ps1
# Related Kaseya Agent Procedure: "Audit - Windows - Get Current Free Disk On C"
# Script description: Get the free disk on C in GB.
# Upload this Powershell script to your Kaseya Agent Procedures folder "VSASharedFiles\UpstreamPowerPack\Powershell".
# Dependencies: Existing registry values
# Supported OS: Windows
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

$FreeDisk = get-wmiobject win32_logicaldisk |foreach-object {[math]::truncate($_.freespace / 1GB)}

# Let's write the current free disk in GB for Kaseya VSA to pick up as a variable.
Write-Output $FreeDisk
