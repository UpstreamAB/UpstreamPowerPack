<#
=================================================================================
Filename:           RMM-Audit-Win10-GetLatestRestorePointDate.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-12-10
=================================================================================
#>

$LatestRestorePointDate = [Management.ManagementDateTimeConverter]::ToDateTime((Get-ComputerRestorePoint | Select-Object CreationTime, Description)[-1].CreationTime).ToString('yyyy-MM-dd')

Write-Output "UPSTREAM: Latest Restore Point: $LatestRestorePointDate"
Write-Output "UPSTREAM: Restore Point History:"
Get-ComputerRestorePoint | Select-Object Creationtime, Description, SequenceNumber, RestorePointType
