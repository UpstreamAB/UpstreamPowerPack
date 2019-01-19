# Script name: RMM-AppMgmt-Windows-DiskCleanup.ps1
# Script type: Powershell
# Script description: .
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

# First, let's have a look at current disk space free.
$CurrentFreeDiskInfo = Get-WmiObject Win32_logicaldisk -ComputerName LocalHost `
| Format-Table DeviceID, MediaType, `
			   @{ Name = "Size(GB)"; Expression = { [decimal]("{0:N0}" -f ($_.size/1gb)) } }, `
			   @{ Name = "Free Space(GB)"; Expression = { [decimal]("{0:N0}" -f ($_.freespace/1gb)) } }, `
			   @{ Name = "Free (%)"; Expression = { "{0,6:P0}" -f (($_.freespace/1gb) / ($_.size/1gb)) } } `
			   -AutoSize

Write-Output "UPSTREAM: Disk space before cleanup: "$CurrentFreeDiskInfo

# Let's call Windows internal diskcleaner and let it it's thing.
Write-Output "UPSTREAM: Attemtig to do some disk cleanup with Cleanmgr. Wait for it...
Start-Process -FilePath Cleanmgr -ArgumentList '/autoclean' -Wait

# Now, let's figure our if Cleanmgr did it's job.
$CurrentFreeDiskInfo = Get-WmiObject Win32_logicaldisk -ComputerName LocalHost `
| Format-Table DeviceID, MediaType, `
			   @{ Name = "Size(GB)"; Expression = { [decimal]("{0:N0}" -f ($_.size/1gb)) } }, `
			   @{ Name = "Free Space(GB)"; Expression = { [decimal]("{0:N0}" -f ($_.freespace/1gb)) } }, `
			   @{ Name = "Free (%)"; Expression = { "{0,6:P0}" -f (($_.freespace/1gb) / ($_.size/1gb)) } } `
			   -AutoSize

Write-Output "UPSTREAM: Disk space after cleanup: "$CurrentFreeDiskInfo
