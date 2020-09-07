<#
=================================================================================
Filename:           RMM-Audit-Win10-GetGPUDriverAndModel.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-07-06
=================================================================================
#>

$GPUModel = Get-WmiObject Win32_VideoController | Select -Expand Caption
$GPUDriver = Get-WmiObject Win32_VideoController | Select -Expand DriverVersion

Write-Output "UPSTREAM: Extended Audit: GPU Model And Driver: Model: $GPUModel"
Write-Output "UPSTREAM: Extended Audit: GPU Model And Driver: Driver: $GPUDriver"
