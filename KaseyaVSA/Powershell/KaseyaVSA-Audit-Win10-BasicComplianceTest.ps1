<#
    ===========================================================================
        Filename:           KaseyaVSA-Audit-Win10-BasicComplianceTest.ps1
        Agent Procedure:    Audit - Windows 10 - Custom Field - Basic Compliance Test
        Created by:         powerpack@upstream.se
        Organization:       Upstream AB, https://en.upstream.se/powerpack
    ===========================================================================

.SYNOPSIS
To be used for pro-actively catch Windows 10 computers out of compliance. Configure the variables in the VARIABLES section to your threshold needs.

.DESCRIPTION
Test: Windows Update.
Test: Last reboot time
Test: Available disk space

.LINK
Upstream Power Pack: https://en.upstream.se/powerpack
Upstream Power Pack mailing list: https://upstream.us19.list-manage.com/subscribe?u=70733bc93d986c3f32bfb0d48&id=c22d15864a
#>

# --------------------------------------------------------------------------------------------------------------------------------
# VARIABLES & OPTIONS


# Test: Missing patches from Windows Update
# What is the compliant number of missing patches in the compliance test?
$AllowedNumberOfMissingPatches = "3"


# Test: Last reboot time
# What is the compliant uptime number in days in the compliance test?
$AllowedNumberOfDaysWithoutReboot = "10"


# Test: Available disk space
# What is the compliant numbers for available disk space in GB?
$AllowedMinimumDiskFree = "20"


# END OF VARIABLES & OPTIONS
# -----------------------------------------------------------------------------------------------------------------------


# STANDARD PREPARATIONS
# -----------------------------------------------------------------------------------------------------------------------


# The start date and time of the compliance test.
$StartDateTime = Get-Date
Write-Output "UPSTREAM: Compliance test started: $StartDateTime"

# Current user.
$CurrentUser = (Get-WMIObject -Class Win32_ComputerSystem | Select UserName).UserName

# At script start the variable $IsComputerCompliant is always "YES". If any test fails it will be set to "NO".
$IsComputerCompliant = "YES"

# Checking for required NuGet Package Provider and either update or install if needed.
Write-Output "UPSTREAM: Preparations: Checking for required Powershell components. Install if missing."

If ((Get-PackageProvider -Name NuGet).version -lt 2.8.5.201){
    Try{
        Write-Host "UPSTREAM: Preparations: Installing NuGet."
        Install-PackageProvider -Name NuGet -Confirm:$False -MinimumVersion 2.8.5.201 -Force}
    
    Catch [Exception]{
        $_.message 
        Exit}
}

Else{
    Write-Host "UPSTREAM: Preparations: NuGet already installed."}

# Checking for required PSWindowsUpdate Powershell module and either update or install if needed.
If (Get-Module -ListAvailable -Name PSWindowsUpdate){
    Write-Host "UPSTREAM: Preparations: PSWindowsUpdate module already installed."
    Update-Module PSWindowsUpdate} 

Else{
    Try {
        Write-Host "UPSTREAM: Preparations: Installing PSWindowsUpdate module."
        Install-Module PSWindowsUpdate -AllowClobber -Confirm:$False -Force -Verbose:$False}
    
    Catch [Exception] {
        $_.message 
        Exit
    }
}

Write-Output "UPSTREAM: Preparations: Completed."
Write-Output "UPSTREAM: Current user: $CurrentUser"


# END OF STANDARD PREPARATIONS
# -----------------------------------------------------------------------------------------------------------------------


# Test: Missing patches from Windows Update
# -----------------------------------------------------------------------------------------------------------------------

$Updates = Get-WuInstall
$UpdateNumber = ($Updates.kb).count

# Ok, here comes the logic. If this computer are missing more than $AllowedNumberOfMissingPatches Windows Updates the compliance will be set to NO.
If ($UpdateNumber -gt $AllowedNumberOfMissingPatches){
    Write-Output "UPSTREAM: Windows Update: Number of missing Windows Updates: $UpdateNumber"
    Write-Output "UPSTREAM: Windows Update: Missing more than $AllowedNumberOfMissingPatches Windows Updates: YES"
    Write-Output "UPSTREAM: Windows Update: Is Windows Update compliant: NO"
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Windows Update: Number of missing Windows Updates: $UpdateNumber"
    Write-Output "UPSTREAM: Windows Update: Missing more than $AllowedNumberOfMissingPatches Windows Updates: NO"
    Write-Output "UPSTREAM: Windows Update: Is Windows Update compliant: YES"}


# Test: Last reboot time
# -----------------------------------------------------------------------------------------------------------------------

function Get-Uptime {
   $os = Get-WmiObject win32_operatingsystem
   $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
   $Display = + $Uptime.Days
   Write-Output $Display
}

# The number of days since last reboot from above function.
$LastRebootInDays = Get-Uptime

# Ok, here comes the logic. If this computer have more than $AllowedNumberOfDaysWithoutReboot days of Reboot compliance will be set to NO.
If ($LastRebootInDays -gt $AllowedNumberOfDaysWithoutReboot){
    Write-Output "UPSTREAM: Windows Reboot: Last reboot was $LastRebootInDays days ago"
    Write-Output "UPSTREAM: Windows Reboot: Last reboot more than $AllowedNumberOfDaysWithoutReboot ago: YES"
    Write-Output "UPSTREAM: Windows Reboot: Is Windows last reboot compliant: NO"
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Windows Reboot: Last reboot was $LastRebootInDays days ago."
    Write-Output "UPSTREAM: Windows Reboot: Reboot more than $AllowedNumberOfDaysWithoutReboot days ago: NO"
    Write-Output "UPSTREAM: Windows Reboot: Is Windows last reboot compliant: YES"}


# Test: Available disk space
# -----------------------------------------------------------------------------------------------------------------------

$FreeSpace = ( Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $env:SystemDrive } ).FreeSpace / 1GB
$FreeSpace = [math]::Round($Freespace,0)

If ($FreeSpace -gt $AllowedMinimumDiskFree){
    Write-Output "UPSTREAM: Available Disk: Available disk: $FreeSpace GB"
    Write-Output "UPSTREAM: Available Disk: Less than $AllowedMinimumDiskFree GB: NO"
    Write-Output "UPSTREAM: Available Disk: Is available disk compliant: YES"}

Else{
    Write-Output "UPSTREAM: Available Disk: Available disk: $FreeSpace GB"
    Write-Output "UPSTREAM: Available Disk: Less than $AllowedMinimumDiskFree GB: YES"
    Write-Output "UPSTREAM: Available Disk: Is available disk compliant: NO"
    $IsComputerCompliant = "NO"}


# End of the line for the Compliance Thest. It's either YES or NO, nothing in between.
# -----------------------------------------------------------------------------------------------------------------------

Write-Output "UPSTREAM: Is this computer compliant: $IsComputerCompliant"


# The end date and time of the compliance test.
$EndDateTime = Get-Date
Write-Output "UPSTREAM: Compliance test ended: $EndDateTime"
Write-Output "Powered by Upstream Power Pack https://en.upstream.se/powerpack"
