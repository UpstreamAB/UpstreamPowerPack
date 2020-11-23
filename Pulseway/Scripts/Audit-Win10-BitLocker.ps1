<#
Pulseway script:    Audit: Win10: BitLocker Status
Support type:       Upstream Pulseway Power Free
Support:            Upstream AB, powerpack@upstream.se
Lastest version:    2020-10-28
Required variable inputs:
None

Required variable outputs:
Name: "OutputBitLockerRecoveryPassword"
Default Value: "Not Detected"
Associated Custom Field: "OS: Bitlocker: Recovery Password"

Name: "OutputBitlockerStatus"
Default Value: "Off"
Associated Custom Field: "OS: Bitlocker: Status"
#>

$OutputBitlockerStatus = (Get-BitLockerVolume -MountPoint "$Env:SystemDrive").ProtectionStatus
Write-Output "UPSTREAM: Basic: Extended Audit: Bitlocker: Status: $OutputBitlockerStatus"
Start-Process -FilePath "$env:PWY_HOME\CLI.exe" -ArgumentList ("setVariable OutputBitlockerStatus $OutputBitlockerStatus") -Wait

$OutputBitLockerRecoveryPassword = (Get-BitLockerVolume -MountPoint "$Env:SystemDrive").KeyProtector.RecoveryPassword
Write-Output "UPSTREAM: Basic: Extended Audit: Bitlocker: Recovery Password: $OutputBitLockerRecoveryPassword"
Start-Process -FilePath "$env:PWY_HOME\CLI.exe" -ArgumentList ("setVariable OutputBitLockerRecoveryPassword $OutputBitLockerRecoveryPassword") -Wait
