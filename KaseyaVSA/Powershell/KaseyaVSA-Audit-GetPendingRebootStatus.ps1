# Script name: KaseyaVSA-Audit-GetPendingRebootStatus.ps1
# Related Kaseya Agent Procedure: "Patch Mgmnt - Windows 10 - Get Pending Reboot Status"
# Script description: Audit if Windows is in apending reboot state from Windows Update.
# Upload this Powershell script to your Kaseya Agent Procedures, Manged Files folder "VSASharedFiles\UpstreamPowerPack\Powershell".
# Supported OS: Windows 10, PendingReboot Powershell module.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

If (Get-Module -ListAvailable -Name PendingReboot){
    Update-Module PendingReboot} 

Else{
    Try {
        Install-Module PendingReboot -AllowClobber -Confirm:$False -Force -Verbose:$False}
    Catch [Exception] {
        $_.message 
        Exit
    }
}

Test-PendingReboot -SkipConfigurationManagerClientCheck
