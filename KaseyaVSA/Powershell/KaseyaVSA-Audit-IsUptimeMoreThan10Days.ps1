# Script name: KaseyaVSA-Audit-IsUptimeMoreThan10Days.ps1
# Related Kaseya Agent Procedure: "User Experience - Windows 10 - Send Message For Reboot If Uptime Is More Than 10 Days"
# Script description: Get the number of days since last real/cold system reboot. The result will be used to prompt the user for reboot if more than 10 days uptime.
# Upload this Powershell script to your Kaseya Agent Procedures folder "VSASharedFiles\UpstreamPowerPack\Powershell".
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack"

$AllowedNumberOfDaysWithoutReboot = "10"

function Get-Uptime {
   $os = Get-WmiObject win32_operatingsystem
   $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
   $Display = + $Uptime.Days
   Write-Output $Display
}

# The number of days since last reboot from above function.
$LastRebootInDays = Get-Uptime

# Ok, here comes the logic. If this computer have more than $AllowedNumberOfDaysWithoutReboot days the output will be True.
If ($LastRebootInDays -gt $AllowedNumberOfDaysWithoutReboot){
    Write-Output "UPSTREAM: Windows Reboot: Last reboot was $LastRebootInDays ago. Windows needs to be rebooted: True"}

Else{
    Write-Output "UPSTREAM: Windows Reboot: Last reboot was $LastRebootInDays ago. Windows needs to be rebooted: False"}
