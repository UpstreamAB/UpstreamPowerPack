# Script name: KaseyaVSA-Audit-GetCurrentFreeDiskOnC.ps1
# Related Kaseya Agent Procedure: "Audit - Windows - Get Current Free Disk On C"
# Script description: Audit the Azure tenant name on a Windows 10 computer
# Dependencies: Existing registry values
# Supported OS: Windows
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object FreeSpace

# Let's write the current free disk in GB for Kaseya VSA to pick up as a variable.
# Write-Host ("{0}GB total" -f [math]::truncate($disk.Size / 1GB))
Write-Output ("{0}GB" -f [math]::truncate($disk.FreeSpace / 1GB))
