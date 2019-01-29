# Script name: RMM-AppMgmt-Windows-DiskCleanup.ps1
# Script type: Powershell
# Script description: .
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

$CurrentFreeDiskInfo = Get-WmiObject Win32_logicaldisk -ComputerName LocalHost `
| Format-Table DeviceID, MediaType, `
			   @{ Name = "Size(GB)"; Expression = { [decimal]("{0:N0}" -f ($_.size/1gb)) } }, `
			   @{ Name = "Free Space(GB)"; Expression = { [decimal]("{0:N0}" -f ($_.freespace/1gb)) } }, `
			   @{ Name = "Free (%)"; Expression = { "{0,6:P0}" -f (($_.freespace/1gb) / ($_.size/1gb)) } } `
			   -AutoSize

Write-Output "UPSTREAM: Disk space before cleanup: "$CurrentFreeDiskInfo

Write-Output "UPSTREAM: Let's call for cleanmgr.exe and let it do the work. Wait for it..."
Start-Process -FilePath Cleanmgr -ArgumentList '/autoclean' -Wait

$CurrentFreeDiskInfo = Get-WmiObject Win32_logicaldisk -ComputerName LocalHost `
| Format-Table DeviceID, MediaType, `
			   @{ Name = "Size(GB)"; Expression = { [decimal]("{0:N0}" -f ($_.size/1gb)) } }, `
			   @{ Name = "Free Space(GB)"; Expression = { [decimal]("{0:N0}" -f ($_.freespace/1gb)) } }, `
			   @{ Name = "Free (%)"; Expression = { "{0,6:P0}" -f (($_.freespace/1gb) / ($_.size/1gb)) } } `
			   -AutoSize

Write-Output "UPSTREAM: Disk space after cleanup: "$CurrentFreeDiskInfo
