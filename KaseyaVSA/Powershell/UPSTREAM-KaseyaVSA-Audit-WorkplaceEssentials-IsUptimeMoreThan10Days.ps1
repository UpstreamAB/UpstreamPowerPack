<#
=================================================================================
Filename:           UPSTREAM-KaseyaVSA-Audit-WorkplaceEssentials-IsUptimeMoreThan10Days.ps1
Kaseya Procedure:   Policy Mgmt - Windows 10 - Send Message If Uptime Is More Than 10 Days
Support type:       Upstream Premium Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-04-22
=================================================================================
#>


# --------------------------------------------------------------------------------------------------------------------------------
# VARIABLES & OPTIONS

$AllowedNumberOfDaysWithoutReboot = "10"

# END OF VARIABLES & OPTIONS
# -----------------------------------------------------------------------------------------------------------------------

Function Get-Uptime {
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
