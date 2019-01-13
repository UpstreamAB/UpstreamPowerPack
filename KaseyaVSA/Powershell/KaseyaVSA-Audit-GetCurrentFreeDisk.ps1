# Script name: KaseyaVSA-Audit-GetCurrentFreeDisk.ps1
# Related Kaseya Agent Procedure: "Audit - Windows - Get Current Free Disk"
# Script description: Audit the Azure tenant name on a Windows 10 computer
# Dependencies: Existing registry values
# Supported OS: Windows
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

$DiskInfo = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" | Where-Object DeviceID -Like C:
$DiskFree = [math]::round($DiskInfo.FreeSpace/1GB, 0)
# Let's write the current free disk in GB for Kaseya VSA to pick up as a variable.
Write-Output $DiskFree
