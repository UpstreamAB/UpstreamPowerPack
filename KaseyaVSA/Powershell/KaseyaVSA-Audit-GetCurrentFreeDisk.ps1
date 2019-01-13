# Script name: KaseyaVSA-Audit-GetCurrentFreeDisk.ps1
# Related Kaseya Agent Procedure: "Audit - Windows 10 - Custom Field - Azure AD Info"
# Script description: Audit the Azure tenant name on a Windows 10 computer
# Dependencies: Existing registry values
# Supported OS: Windows
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

$CurrentFreeDisk = Get-WmiObject Win32_logicaldisk -ComputerName LocalHost `
| Format-Table @{ Name = "Size(GB)"; Expression = { [decimal]("{0:N0}" -f ($_.size/1gb)) } }, `
			   @{ Name = "Free Space(GB)"; Expression = { [decimal]("{0:N0}" -f ($_.freespace/1gb)) } }, `
			   @{ Name = "Free (%)"; Expression = { "{0,6:P0}" -f (($_.freespace/1gb) / ($_.size/1gb)) } } `
			   -AutoSize
# Let's write the current free disk infomation to the concole for Kaseya VSA to pick up as a variable.
Write-Output $CurrentFreeDisk
