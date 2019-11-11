<#
    ===========================================================================
        Filename:       RMM-Audit-Win10-ComputerComplianceTest.ps1
        Latest update:  2019-11-01
        Created by:     powerpack@upstream.se
        Organization:   Upstream AB, https://en.upstream.se/powerpack
    ===========================================================================

.SYNOPSIS
To be used for pro-actively catch Windows 10 computers out of secuirity and quality compliance.

.DESCRIPTION
Windows Update: Missing more than X number of patches.
Windows Firewall: Profiles enabled or not.
Anti-Virus: Enabled and definition up to date?
Windows Reboot: Computer rebooted more than X days ago.
Unexpected Shutdowns: More than X times within X number of days.
Application Errors: More than X times within X number of days.
Available Disk: Less than X GB.
Additional Windows Event Log will be created if the computer is out of compliance to be used with any Event Log parser.
LogName "System" Source "UpstreamPowerPack" EventId "10" Entrytype "Information" ;essage "UPSTREAM: Compliance Test: Is this computer compliant: NO"

.EXAMPLE
Execute in the Powershell console as Administrator. Configure the variables in the #VARIABLES section to your threshold needs.

.NOTES
Changelog
2019-11-11: Added variable $AppendErrorMessage for detailed log output to Event Log message when test(s) fail.
            Removed App Crash, Hang and Unexpected Shutdown Event Log messages to Write-Oupout as it became to messy if many entries.
2019-11-01: First version.

.LINK
Upstream Power Pack: https://en.upstream.se/powerpack/
mailing list: https://upstream.us19.list-manage.com/subscribe?u=70733bc93d986c3f32bfb0d48&id=c22d15864a
Slack channel: https://join.slack.com/t/upstreampowerpack/shared_invite/enQtNTM2NTgyNjc5NjY3LTM0NTk1MzNjNmM4NWJiNjM4MzkwMDliNjA4N2Q0MzMxMGZkODdiOTczMjAwM2ExMTNkMTM3YzA1ZGU2MjVjYzE
#>

# --------------------------------------------------------------------------------------------------------------------------------
# VARIABLES

# Windows Update test
# What is the allowed number of missing patches?
$AllowedNumberOfMissingPatches = "2"

# Windows last reboot test
# What is the allowed number of days without reboot?
$AllowedNumberOfDaysWithoutReboot = "7"

# Windows Anti-Virus test
# If you want Windows Defender to be included in the test, edit the line 112 and remove: -ne "Windows Defender".
# Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct | Where DisplayName -ne "Windows Defender"
# We will add this as variable option coming releases.


# Windows Firewall test
# As for now wer are testing all the 3 available profiles.
# We will add this as variable option coming releases.

# Unexpected Shutdown test
$NumberOfDaysBackLookingForUnexpectedShutdowns = "30"
$AllowedNumberOfUnexpectedShutdowns = "1"

# Applciation Error & Hangs test
$NumberOfDaysBackLookingForApplicationErrors = "30"
$AllowedNumberOfapplicationErrors = "1"

# Avialable Disk test
$AllowedMinimumDiskFree = "20"

# This is the beginning of the Event Log error message if test failed in any of the sections below.
$AppendErrorMessage = "Detailed error messages from the failed test(s):`r----------------------------------------------------`r"

# END OF VARIABLES
# -----------------------------------------------------------------------------------------------------------------------

# PREPARATIONS
# -----------------------------------------------------------------------------------------------------------------------
$StartDate = (Get-Date)
Write-Output "UPSTREAM: Compliance Test: Started $StartDate"

# At script start the variable $IsComputerCompliant is always "YES". If any test fails it will be set to "NO".
$IsComputerCompliant = "YES"

# Checking for required NuGet Package Provider and PSWindowsUpdate Powershell module from PSGallery.
If(-not(Get-PackageProvider NuGet -ErrorAction SilentlyContinue))
    {
        Write-Output "UPSTREAM: Compliance Test: Required NuGet package provider missing. Installing."
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force}
        
If(-not(Get-InstalledModule PSWindowsUpdate -ErrorAction SilentlyContinue))
    {
        Write-Output "UPSTREAM: Compliance Test: Required PSWindowsUpdate Module missing. Installing." 
        Set-PSRepository PSGallery -InstallationPolicy Trusted
        Install-Module PSWindowsUpdate -AllowClobber -Confirm:$False -Force}

# END OF PREPARATIONS
# -----------------------------------------------------------------------------------------------------------------------

# Test: Check Windows Update status
# -----------------------------------------------------------------------------------------------------------------------
Write-Output "UPSTREAM: Compliance Test: Windows Update: Scanning for missing Windows Updates."

$updates = Get-WuInstall
# You could also get the pending reboot status back as False or True. We will not use that option in the current version. We only check if reboot is more than X days below.
# $RebootRequired = Get-WURebootStatus | Select -Expand RebootREquired

$UpdateNumber = ($Updates.kb).count

Write-Output "UPSTREAM: Compliance Test: Windows Update: Number of missing Windows Updates: $updatenumber"

# Ok, here comes the logic. If this computer are missing more than $AllowedNumberOfMissingPatches Windows Updates the compliance will be set to NO.
If ($UpdateNumber -gt $AllowedNumberOfMissingPatches){
    Write-Output "UPSTREAM: Compliance Test: Windows Update: Missing more than $AllowedNumberOfMissingPatches Windows Updates: YES`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Compliance Test: Windows Update: Is Windows Update compliant: NO`r" -Outvariable +AppendErrorMessage
    Write-Output "$Updates`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Compliance Test: Windows Update: Missing more than $AllowedNumberOfMissingPatches Windows Updates: NO"
    Write-Output "UPSTREAM: Compliance Test: Windows Update: Is Windows Update compliant: YES"}


# Test: Check Windows Firewall status
# -----------------------------------------------------------------------------------------------------------------------
$FirewallStatus = 0
$SysFirewallReg1 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg1 -eq 1){
    Write-Output "UPSTREAM: Compliance Test: Windows Firewall: Domain Profile enabled: YES"
    $FirewallStatus = 1}

Else{
    Write-Output "UPSTREAM: Compliance Test: Windows Firewall: Domain Profile enabled: NO`r" -Outvariable +AppendErrorMessage}

$SysFirewallReg2 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg2 -eq 1){
    Write-Output "UPSTREAM: Compliance Test: Windows Firewall: Public Profile enabled: YES"
    $FirewallStatus = ($FirewallStatus + 1)}

Else{
    Write-Output "UPSTREAM: Compliance Test: Windows Firewall: Public Profile enabled: NO`r" -Outvariable +AppendErrorMessage}


$SysFirewallReg3 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg3 -eq 1){
    $FirewallStatus = ($FirewallStatus + 1)
    Write-Output "UPSTREAM: Compliance Test: Windows Firewall: Standard Profile enabled: YES"}

Else{
    Write-Output "UPSTREAM: Compliance Test: Windows Firewall: Standard Profile enabled: NO`r" -Outvariable +AppendErrorMessage}

# Ok, here comes the logic. If any of the profiles above are disabled the compliance will be set to NO.
If ($FirewallStatus -eq 3){
    Write-Output "UPSTREAM: Compliance Test: Windows Firewall: Is Windows Firewall compliant: YES"}

Else{
    Write-Output "UPSTREAM: Compliance Test: Windows Firewall: Is Windows Firewall compliant: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}


# Test: Check for Anti-Virus status.
# -----------------------------------------------------------------------------------------------------------------------
function Get-AntiVirusProduct {
[CmdletBinding()]
    param (
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('name')]
    $computername=$env:computername
    )
    
    $AntiVirusProducts = Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct | Where DisplayName -ne "Windows Defender"

    $ret = @()
        foreach($AntiVirusProduct in $AntiVirusProducts){
        # Switch to determine the status of antivirus definitions and real-time protection.
        # The values in this switch-statement are retrieved from the following website: http://community.kaseya.com/resources/m/knowexch/1020.aspx
        switch ($AntiVirusProduct.productState) {
        "262144" {$defstatus = "Up to date" ;$rtstatus = "Disabled"}
        "262160" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}
        "266240" {$defstatus = "Up to date" ;$rtstatus = "Enabled"}
        "266256" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}
        "393216" {$defstatus = "Up to date" ;$rtstatus = "Disabled"}
        "393232" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}
        "393488" {$defstatus = "Out of date" ;$rtstatus = "Disabled"}
        "397312" {$defstatus = "Up to date" ;$rtstatus = "Enabled"}
        "397328" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}
        "397584" {$defstatus = "Out of date" ;$rtstatus = "Enabled"}
        default {$defstatus = "Unknown" ;$rtstatus = "Unknown"}
            }

        #Create hash-table for the computer for a detailed output.
        $ht = @{}
        $ht.Name = $AntiVirusProduct.displayName
        $ht.'Product GUID' = $AntiVirusProduct.instanceGuid
        $ht.'Product Executable' = $AntiVirusProduct.pathToSignedProductExe
        $ht.'Reporting Exe' = $AntiVirusProduct.pathToSignedReportingExe
        $ht.'Definition Status' = $defstatus
        $ht.'Real-time Protection Status' = $rtstatus

        #Create a new object for the computer
        $ret += New-Object -TypeName PSObject -Property $ht 
    }
    Return $ret
} 

$AVRealTimeProtectionStatus = Get-AntiVirusProduct | Select "Real-time Protection Status"
$AVDefinitionStatus = Get-AntiVirusProduct | Select "Definition Status"

# Ok, here comes the logic. If this computer are reporting $AVRealTimeProtectionStatus as anything else than "Enabled" the compliance will be set to NO.
If ($AVRealTimeProtectionStatus -Match "Enabled"){
    Write-Output "UPSTREAM: Compliance Test: Anti-Virus: Real-time protection enabled: YES"} 

Else{
    Write-Output "UPSTREAM: Compliance Test: Anti-Virus: Real-time protection enabled: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

# Ok, here comes the logic. If this computer are reporting $AVDefinitionStatus as anything else than "Up to date" the compliance will be set to NO.
If ($AVDefinitionStatus -Match "Up to date"){
    Write-Output "UPSTREAM: Compliance Test: Anti-Virus: Definition up to date: YES"}

Else{
    Write-Output "UPSTREAM: Compliance Test: Anti-Virus: Definition up to date: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

# Ok, here comes the logic. If this computer are reporting $AVRealTimeProtectionStatus OR as $AVDefinitionStatus as "NO" the the whole Anti-Virus compliance test will be set to NO.
If ($AVRealTimeProtectionStatus -Match "NO" -Or $AVDefinitionStatus -Match "NO"){
    Write-Output "UPSTREAM: Compliance Test: Anti-Virus: Is Anti-Virus compliant: NO`r" -Outvariable +AppendErrorMessage
    Get-AntiVirusProduct}

Else{
    Write-Output "UPSTREAM: Compliance Test: Anti-Virus: Is Anti-Virus compliant: YES"}

# Test: Last reboot
# -----------------------------------------------------------------------------------------------------------------------
function Get-Uptime {
   $os = Get-WmiObject win32_operatingsystem
   $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
   $Display = + $Uptime.Days
   Write-Output $Display
}

# The number of days since last reboot from above function.
$LastRebootInDays = Get-Uptime

Write-Output "UPSTREAM: Compliance Test: Windows Reboot: Last reboot was $LastRebootInDays days ago."

# Ok, here comes the logic. If this computer have more than $AllowedNumberOfDaysWithoutReboot days of Reboot compliance will be set to NO.
If ($LastRebootInDays -gt $AllowedNumberOfDaysWithoutReboot){
    Write-Output "UPSTREAM: Compliance Test: Windows Reboot: Last reboot more than $AllowedNumberOfDaysWithoutReboot ago: YES`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Compliance Test: Windows Reboot: Is Windows Reboot compliant: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Compliance Test: Windows Reboot: Reboot more than $AllowedNumberOfDaysWithoutReboot days: NO"
    Write-Output "UPSTREAM: Compliance Test: Windows Reboot: Is Windows last reboot compliant: YES"}

# Test: Unexpected shutdowns in the Windows Event Log.
# -----------------------------------------------------------------------------------------------------------------------
$UnexpectedShutdownEvents = Get-EventLog -LogName System -EntryType Error -After ([DateTime]::Today.AddDays(-$NumberOfDaysBackLookingForUnexpectedShutdowns))| Where-Object {$_.EventID -eq 6008}
$NumberOfUnexpectedShutdowns = ($UnexpectedShutdownEvents.EventID).count

If ($NumberOfUnexpectedShutdowns -gt $AllowedNumberOfUnexpectedShutdowns){
    Write-Output "UPSTREAM: Compliance Test: Unexpected Shutdowns: Detected shutdowns within $NumberOfDaysBackLookingForUnexpectedShutdowns days: $NumberOfUnexpectedShutdowns`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Compliance Test: Unexpected Shutdowns: More than $AllowedNumberOfUnexpectedShutdowns within $NumberOfDaysBackLookingForUnexpectedShutdowns days: YES`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Compliance Test: Unexpected Shutdowns: Is Unexpected shutdowns compliant: NO"
    #Write-Output "$UnexpectedShutdownEvents`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Compliance Test: Unexpected Shutdowns: Detected shutdowns within $NumberOfDaysBackLookingForUnexpectedShutdowns days: $NumberOfUnexpectedShutdowns"
    Write-Output "UPSTREAM: Compliance Test: Unexpected Shutdowns: Shutdowns more than $AllowedNumberOfUnexpectedShutdowns within $NumberOfDaysBackLookingForUnexpectedShutdowns days: NO"}
    Write-Output "UPSTREAM: Compliance Test: Unexpected Shutdowns: Is Unexpected shutdowns compliant: YES"

# Test: Application hangs and errors in the Windows Event Log.
# -----------------------------------------------------------------------------------------------------------------------
$ApplicationErrorEvents = Get-EventLog -LogName Application -EntryType Error -After ([DateTime]::Today.AddDays(-$NumberOfDaysBackLookingForApplicationErrors))| Where-Object {$_.EventID -eq 1000 -or $_.EventID -eq 1002}
$NumberApplicationErrorEvents = ($ApplicationErrorEvents.EventID).count

If ($NumberApplicationErrorEvents -gt $AllowedNumberOfapplicationErrors){
    Write-Output "UPSTREAM: Compliance Test: Number of application errors detected within $NumberOfDaysBackLookingForApplicationErrors days: $NumberApplicationErrorEvents"
    Write-Output "UPSTREAM: Compliance Test: Application Errors: More than $AllowedNumberOfapplicationErrors whitin $NumberOfDaysBackLookingForApplicationErrors days: YES"
    Write-Output "UPSTREAM: Compliance Test: Application Errors: Is Application errors compliant: NO"
    #Write-Output "$ApplicationErrorEvents`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Compliance Test: Number of application errors detected within $NumberOfDaysBackLookingForApplicationErrors days: $NumberApplicationErrorEvents"
    Write-Output "UPSTREAM: Compliance Test: Application Errors: More than $AllowedNumberOfapplicationErrors within $NumberOfDaysBackLookingForApplicationErrors days: NO"}
    Write-Output "UPSTREAM: Compliance Test: Application Errors: Is Application errors compliant: YES"

# Test: Available disk on system drive.
# -----------------------------------------------------------------------------------------------------------------------
$FreeSpace = ( Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $env:SystemDrive } ).FreeSpace / 1GB
$FreeSpace = [math]::Round($Freespace,0)

If ($FreeSpace -gt $AllowedMinimumDiskFree){
    Write-Output "UPSTREAM: Compliance Test: Available Disk: Available disk: $FreeSpace GB"
    Write-Output "UPSTREAM: Compliance Test: Available Disk: Less than $AllowedMinimumDiskFree GB: NO"
    Write-Output "UPSTREAM: Compliance Test: Available Disk: Is available disk compliant: YES"}

Else{
    Write-Output "UPSTREAM: Compliance Test: Available Disk: Available disk: $FreeSpace GB`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Compliance Test: Available Disk: Less than $AllowedMinimumDiskFree GB: YES`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Compliance Test: Available Disk: Is available disk compliant: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

# End of the line for the Compliance Thest. It's either YES or NO, nothing in between. If compliance is "NO" a custom Windows Event Set
# will be created to be used with most RMM's Event Log parsing capabilities.
# -----------------------------------------------------------------------------------------------------------------------

Write-Output "UPSTREAM: Compliance Test: Is this computer compliant: $IsComputerCompliant"

If ($IsComputerCompliant -Match "NO"){
    Write-Output "UPSTREAM: Compliance Test: One Windows Event Log was created for your RMM to pick up."
    $UpstreamPowerPacklogFileExists = [System.Diagnostics.EventLog]::SourceExists("UpstreamPowerPack")
        
    If ($UpstreamPowerPacklogFileExists -Match "True"){
    # UpstreamPowerPack Event Log Source exists on local machine. Nothing to do.
    }
        
    Else{
    # UpstreamPowerPack Event Log Source does not exist. Let's create.
        New-EventLog -LogName System -Source UpstreamPowerPack}

    # This line will create the Windows Event Log for your RMM to pick up.
    Write-EventLog -LogName System -Source UpstreamPowerPack -EventId 10 -Entrytype Information -Message "UPSTREAM: Compliance Test: Is this computer compliant: NO`r$AppendErrorMessage`rPowered by Upstream Power Pack https://en.upstream.se/powerpack"
}

$EndDate = (Get-Date)
Write-Output "UPSTREAM: Compliance Test: Ended $EndDate"
Write-Output "Powered by Upstream Power Pack https://en.upstream.se/powerpack"
