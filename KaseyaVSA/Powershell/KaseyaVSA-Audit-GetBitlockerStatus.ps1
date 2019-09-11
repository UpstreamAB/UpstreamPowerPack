# Script name: KaseyaVSA-Audit-GetOSActivation.ps1
# Related Kaseya Agent Procedure: "Audit - Windows - Get Bitlocker Status"
# Script description: Audit if the Windows 10 OS is encryptet with BitLocker.
# Upload this Powershell script to your Kaseya Agent Procedures, Manged Files folder "VSASharedFiles\UpstreamPowerPack\Powershell".
# Supported OS: Windows 10.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack
Get-BitLockerVolume | Select -Expand VolumeStatus
