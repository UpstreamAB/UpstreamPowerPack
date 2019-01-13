# Script name: KaseyaVSA-Audit-GetCurrentFreeDiskOnC.ps1
# Related Kaseya Agent Procedure: "Audit - Windows - Get Current Free Disk On C"
# Script description: Audit the Azure tenant name on a Windows 10 computer
# Dependencies: Existing registry values
# Supported OS: Windows
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

$DiskInfo = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" | Where-Object DeviceID -Like C:
$FreeDisk = [math]::round($DiskInfo.FreeSpace/1GB, 0)
# Let's write the current free disk in GB for Kaseya VSA to pick up as a variable.
Write-Output $FreeDisk
