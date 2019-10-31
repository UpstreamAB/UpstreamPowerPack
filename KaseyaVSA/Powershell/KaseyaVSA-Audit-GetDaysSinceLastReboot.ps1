# Script name: KaseyaVSA-Audit-GetDaysSinceLastReboot.ps1
# Related Kaseya Agent Procedure: "User Experience - Windows 10 - Inform User To Reboot The Computer"
# Script description: Get the number of days since last real system reboot, not just when the system was shut down or hibernated.
# To be used in pop-up messages instructing customers to reboot.
# Upload this Powershell script to your Kaseya Agent Procedures folder "VSASharedFiles\UpstreamPowerPack\Powershell".
# Dependencies: Existing registry values
# Supported OS: Windows 10.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack"

function Get-Uptime {
   $os = Get-WmiObject win32_operatingsystem
   $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
   $Display = + $Uptime.Days
   Write-Output $Display
}

Get-Uptime
