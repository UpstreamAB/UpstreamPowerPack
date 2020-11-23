<#
=================================================================================
Pulseway script:    Audit: Win10: GPU Driver And Model
Support type:       Upstream Pulseway Power Free
Support:            Upstream AB, powerpack@upstream.se
Lastest version:    2020-10-28

Required variable inputs:
None

Required variable outputs:
Name: "OutputGPUDriver"
Default Value: "Not Audited"
Associated Custom Field: "OS: GPU: Driver"

Name: "OutputGPUModel"
Default Value: "Not Audited"
Associated Custom Field: "system: GPU: Model"
=================================================================================
#>

$OutputGPUModel = Get-WmiObject Win32_VideoController | Select -Expand Caption
$OutputGPUDriver = Get-WmiObject Win32_VideoController | Select -Expand DriverVersion

Write-Output "UPSTREAM: Extended Audit: GPU Model And Driver: Model: $GPUModel"
Write-Output "UPSTREAM: Extended Audit: GPU Model And Driver: Driver: $OutputGPUDriver"

Start-Process -FilePath "$env:PWY_HOME\CLI.exe" -ArgumentList ("setVariable OutputGPUModel ""$OutputGPUModel""") -Wait
Start-Process -FilePath "$env:PWY_HOME\CLI.exe" -ArgumentList ("setVariable OutputGPUDriver ""$OutputGPUDriver""") -Wait
