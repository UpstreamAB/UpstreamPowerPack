<#
    ===========================================================================
        Filename:       RMM-Audit-Win10-ComputerComplianceTest.ps1
        Latest update:  2019-11-28
        Created by:     powerpack@upstream.se
        Organization:   Upstream AB, https://en.upstream.se/powerpack
    ===========================================================================

.SYNOPSIS
To be used for pro-actively catch Windows 10 computers out of secuirity and quality compliance. Configure the variables in the #VARIABLES section to your threshold needs.

.DESCRIPTION
Test: Check Windows Update status
Test: Check BitLocker status
Test: Check Windows Firewall status
Test: Check for Anti-Virus status
Test: User Account Control (UAC)
Test: Last reboot
Test: Unexpected shutdowns in the Windows Event Log
Test: Application hangs and errors in the Windows Event Log
Test: Available disk on system drive
Additional Windows Event Log will be created if the computer is out of compliance to be used with any Event Log parser.
LogName "System" Source "UpstreamPowerPack" EventId "10" Entrytype "Information" Message "UPSTREAM: Is this computer compliant: NO"

.EXAMPLE
Execute in the Powershell console as Administrator like ".\RMM-Audit-Win10-ComputerComplianceTest.ps1" or execute from any RMM.

.NOTES
Changelog
2019-11-24: Simplified the the preparation stage for NuGet Package Provider and PSWindUpdate Powershell module.
2019-11-21: Variables: Added variable $AllowTestForBitLocker for BitLocker encryption test. Default is "NO".
2019-11-18: Anti-Virus: Changed If statement from "NotLike" to "NotMatch" for "Enabled" and "Up to date".
2019-11-11: Variables: Added variable $AppendErrorMessage for detailed log output to Event Log message when test(s) fail.
2019-11-01: First version.

.LINK
Upstream Power Pack: https://en.upstream.se/powerpack
Upstream Power Pack mailing list: https://upstream.us19.list-manage.com/subscribe?u=70733bc93d986c3f32bfb0d48&id=c22d15864a
#>

# --------------------------------------------------------------------------------------------------------------------------------
# VARIABLES

# What is the compliant number of missing patches for the Windows Update test?
$AllowedNumberOfMissingPatches = "5"

# What is the compliant number for the Windows Last Reboot test?
$AllowedNumberOfDaysWithoutReboot = "10"

# Would you like to add BitLocker in the compliance test? YES/NO
# The test is successful if C: drive is "FullyEnrypted".
$AllowTestForBitLocker = "YES"

# What is the compliand numbers for the Unexpected Shutdown test?
$NumberOfDaysBackLookingForUnexpectedShutdowns = "30"
$AllowedNumberOfUnexpectedShutdowns = "5"

# What is the compliand numbers for the Applciation Error & Hangs test
$NumberOfDaysBackLookingForApplicationErrors = "30"
$AllowedNumberOfapplicationErrors = "25"

# What is the compliand numbers for the Free Disk test?
$AllowedMinimumDiskFree = "20"

# This is the beginning of the Event Log error message if any test fails in any of the sections below.
$AppendErrorMessage = "Detailed error messages from the failed test(s):`r----------------------------------------------------`rCurrent user: $env:UserName`r"

$AllowTestForWindowsDefender = "YES"

# END OF VARIABLES
# -----------------------------------------------------------------------------------------------------------------------

# PREPARATIONS
# -----------------------------------------------------------------------------------------------------------------------

# Checking for required NuGet Package Provider and either update or install if needed.
Write-Output "UPSTREAM: Preparations: Checking for required Powershell components."
If ((Get-PackageProvider -Name NuGet).version -lt 2.8.5.201){
    Try{
        Write-Host "UPSTREAM: Preparations: Installing NuGet."
        Install-PackageProvider -Name NuGet -Confirm:$False -MinimumVersion 2.8.5.201 -Force}
    
    Catch [Exception]{
        $_.message 
        Exit}
}

Else{
    Write-Host "UPSTREAM: Preparations: NuGet installed."}

# Checking for required PSWindowsUpdate Powershell module and either update or install if needed.
If (Get-Module -ListAvailable -Name PSWindowsUpdate){
    Write-Host "UPSTREAM: Preparations: PSWindowsUpdate module installed."
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

# At script start the variable $IsComputerCompliant is always "YES". If any test fails it will be set to "NO".
$IsComputerCompliant = "YES"

$StartDateTime = Get-Date
Write-Output "UPSTREAM: Compliance test started: $StartDateTime"

# END OF PREPARATIONS
# -----------------------------------------------------------------------------------------------------------------------

# Test: Check Windows Update status
# -----------------------------------------------------------------------------------------------------------------------
# Get all available Windows Updtes from Microsoft
$Updates = Get-WuInstall
# Get the pending reboot status back as False or True. We will use this as additional information when not compliant.
$RebootRequired = Get-WURebootStatus | Select -Expand RebootRequired

$UpdateNumber = ($Updates.kb).count

# Ok, here comes the logic. If this computer are missing more than $AllowedNumberOfMissingPatches Windows Updates the compliance will be set to NO.
If ($UpdateNumber -gt $AllowedNumberOfMissingPatches){
    Write-Output "UPSTREAM: Windows Update: Number of missing Windows Updates: $updatenumber`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Windows Update: Missing more than $AllowedNumberOfMissingPatches Windows Updates: YES`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Windows Update: Pending reboot from Windows update: $RebootRequired`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Windows Update: Is Windows Update compliant: NO`r" -Outvariable +AppendErrorMessage
    Write-Output "$Updates`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Windows Update: Number of missing Windows Updates: $updatenumber`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Windows Update: Missing more than $AllowedNumberOfMissingPatches Windows Updates: NO"
    Write-Output "UPSTREAM: Windows Update: Is Windows Update compliant: YES"}

# Test: Check BitLocker status
# -----------------------------------------------------------------------------------------------------------------------
If ($AllowTestForBitLocker -Match "YES"){
    
    $BitLockerStatus = (manage-bde -status c:)
    # Ok, here comes the logic. If this computer are reporting $AVRealTimeProtectionStatus as anything else than "Enabled" the compliance will be set to NO.
    If ($BitLockerStatus -Match "Fully Encrypted"){
        Write-Output "UPSTREAM: BitLocker: Enabled: YES"
        Write-Output "UPSTREAM: BitLocker: Is BitLocker compliant: YES"} 

    Else{
        Write-Output "UPSTREAM: BitLocker: Enabled: NO`r" -Outvariable +AppendErrorMessage
        Write-Output "UPSTREAM: BitLocker: Is BitLocker compliant: NO`r" -Outvariable +AppendErrorMessage
        Write-Output "UPSTREAM: BitLocker: $BitLockerStatus`r" -Outvariable +AppendErrorMessage
        $IsComputerCompliant = "NO"}
}

# Test: Check Windows Firewall status
# -----------------------------------------------------------------------------------------------------------------------
$FirewallStatus = 0
$SysFirewallReg1 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg1 -eq 1){
    Write-Output "UPSTREAM: Windows Firewall: Domain Profile enabled: YES"
    $FirewallStatus = 1}

Else{
    Write-Output "UPSTREAM: Windows Firewall: Domain Profile enabled: NO`r" -Outvariable +AppendErrorMessage}

$SysFirewallReg2 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg2 -eq 1){
    Write-Output "UPSTREAM: Windows Firewall: Public Profile enabled: YES"
    $FirewallStatus = ($FirewallStatus + 1)}

Else{
    Write-Output "UPSTREAM: Windows Firewall: Public Profile enabled: NO`r" -Outvariable +AppendErrorMessage}


$SysFirewallReg3 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg3 -eq 1){
    $FirewallStatus = ($FirewallStatus + 1)
    Write-Output "UPSTREAM: Windows Firewall: Standard Profile enabled: YES"}

Else{
    Write-Output "UPSTREAM: Windows Firewall: Standard Profile enabled: NO`r" -Outvariable +AppendErrorMessage}

# Ok, here comes the logic. If any of the profiles above are disabled the compliance will be set to NO.
If ($FirewallStatus -eq 3){
    Write-Output "UPSTREAM: Windows Firewall: Is Windows Firewall compliant: YES"}

Else{
    Write-Output "UPSTREAM: Windows Firewall: Is Windows Firewall compliant: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

# Test: Check for Anti-Virus status
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

# Let's create variables of the Anti-Virus status by property.
$AVRealTimeProtectionStatus = Get-AntiVirusProduct | Select -Expand "Real-time Protection Status"
$AVDefinitionStatus = Get-AntiVirusProduct | Select -Expand "Definition Status"
$AVProductExecutable = Get-AntiVirusProduct | Select -Expand "Product Executable"
$AVDetailedStatus = Get-AntiVirusProduct

Write-Output "UPSTREAM: Anti-Virus: Real-Time Protection Status: $AVRealTimeProtectionStatus"
Write-Output "UPSTREAM: Anti-Virus: Product executable: $AVProductExecutable"
# Ok, here comes the logic. If this computer are reporting $AVRealTimeProtectionStatus as anything else than "Enabled" the compliance will be set to NO.
If ($AVRealTimeProtectionStatus -Match "Enabled"){
    Write-Output "UPSTREAM: Anti-Virus: Real-Time Protection enabled: YES"}

Else{
    Write-Output "UPSTREAM: Anti-Virus: Real-time protection enabled: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

Write-Output "UPSTREAM: Anti-Virus: Definition Status: $AVDefinitionStatus"
# Ok, here comes the logic. If this computer are reporting $AVDefinitionStatus as anything else than "Up to date" the compliance will be set to NO.
If ($AVDefinitionStatus -Match "Up to date"){
    Write-Output "UPSTREAM: Anti-Virus: Definition up to date: YES"}

Else{
    Write-Output "UPSTREAM: Anti-Virus: Definition up to date: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

# Ok, here comes the logic. If this computer are reporting $AVRealTimeProtectionStatus does not match "Enabled" OR $AVDefinitionStatus does not match "Up to date" the the whole Anti-Virus compliance test will be set to NO.
If ($AVRealTimeProtectionStatus -NotMatch "Enabled" -Or $AVDefinitionStatus -NotMatch "Up to date"){
    Write-Output "UPSTREAM: Anti-Virus: Is Anti-Virus compliant: NO`r" -Outvariable +AppendErrorMessage
    Write-Output "$AVDetailedStatus`r" -Outvariable +AppendErrorMessage}

Else{
    Write-Output "UPSTREAM: Anti-Virus: Is Anti-Virus compliant: YES"}

# Test: User Account Control (UAC)
# -----------------------------------------------------------------------------------------------------------------------
$UACStatus = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA | Select-Object -Expand EnableLUA

# Ok, here comes the logic. If this computer have more than $AllowedNumberOfDaysWithoutReboot days of Reboot compliance will be set to NO.
If ($UACStatus -eq 1){
    Write-Output "UPSTREAM: UAC: Regsitry value: $UACStatus"
    Write-Output "UPSTREAM: UAC: Enabled: YES"
    Write-Output "UPSTREAM: UAC: Is User Account Control compliant: YES"}

Else{
    Write-Output "UPSTREAM: UAC: Regsitry value: $UACStatus`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: UAC: Is User Account Control enabled: NO`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: UAC: Is User Account Control compliant: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}
    
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

# Ok, here comes the logic. If this computer have more than $AllowedNumberOfDaysWithoutReboot days of Reboot compliance will be set to NO.
If ($LastRebootInDays -gt $AllowedNumberOfDaysWithoutReboot){
    Write-Output "UPSTREAM: Windows Reboot: Last reboot was $LastRebootInDays days ago`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Windows Reboot: Last reboot more than $AllowedNumberOfDaysWithoutReboot ago: YES`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Windows Reboot: Pending reboot from Windows update: $RebootRequired`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Windows Reboot: Is Windows last reboot compliant: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Windows Reboot: Last reboot was $LastRebootInDays days ago."
    Write-Output "UPSTREAM: Windows Reboot: Reboot more than $AllowedNumberOfDaysWithoutReboot days: NO"
    Write-Output "UPSTREAM: Windows Reboot: Is Windows last reboot compliant: YES"}

# Test: Unexpected shutdowns in the Windows Event Log
# -----------------------------------------------------------------------------------------------------------------------
$UnexpectedShutdownEvents = Get-EventLog -LogName System -EntryType Error -After ([DateTime]::Today.AddDays(-$NumberOfDaysBackLookingForUnexpectedShutdowns))| Where-Object {$_.EventID -eq 6008}
$NumberOfUnexpectedShutdowns = ($UnexpectedShutdownEvents.EventID).count

If ($NumberOfUnexpectedShutdowns -gt $AllowedNumberOfUnexpectedShutdowns){
    Write-Output "UPSTREAM: Unexpected Shutdowns: Detected within $NumberOfDaysBackLookingForUnexpectedShutdowns days: $NumberOfUnexpectedShutdowns`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Unexpected Shutdowns: More than $AllowedNumberOfUnexpectedShutdowns within $NumberOfDaysBackLookingForUnexpectedShutdowns days: YES`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Unexpected Shutdowns: Is unexpected shutdowns compliant: NO`r" -Outvariable +AppendErrorMessage
    #Write-Output "$UnexpectedShutdownEvents`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Unexpected Shutdowns: Detected $NumberOfDaysBackLookingForUnexpectedShutdowns within days: $NumberOfUnexpectedShutdowns"
    Write-Output "UPSTREAM: Unexpected Shutdowns: Detected more than $AllowedNumberOfUnexpectedShutdowns within $NumberOfDaysBackLookingForUnexpectedShutdowns days: NO"}
    Write-Output "UPSTREAM: Unexpected Shutdowns: Is unexpected shutdowns compliant: YES"

# Test: Application hangs and errors in the Windows Event Log.
# -----------------------------------------------------------------------------------------------------------------------
$ApplicationErrorEvents = Get-EventLog -LogName Application -EntryType Error -After ([DateTime]::Today.AddDays(-$NumberOfDaysBackLookingForApplicationErrors))| Where-Object {$_.EventID -eq 1000 -or $_.EventID -eq 1002}
$NumberApplicationErrorEvents = ($ApplicationErrorEvents.EventID).count

If ($NumberApplicationErrorEvents -gt $AllowedNumberOfapplicationErrors){
    Write-Output "UPSTREAM: Application Errors: Errors within $NumberOfDaysBackLookingForApplicationErrors days: $NumberApplicationErrorEvents`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Application Errors: More than $AllowedNumberOfapplicationErrors whitin $NumberOfDaysBackLookingForApplicationErrors days: YES`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Application Errors: Is application errors compliant: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Application Errors: Detected within $NumberOfDaysBackLookingForApplicationErrors days: $NumberApplicationErrorEvents"
    Write-Output "UPSTREAM: Application Errors: More than $AllowedNumberOfapplicationErrors within $NumberOfDaysBackLookingForApplicationErrors days: NO"}
    Write-Output "UPSTREAM: Application Errors: Is application errors compliant: YES"

# Test: Available disk on system drive.
# -----------------------------------------------------------------------------------------------------------------------
$FreeSpace = ( Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $env:SystemDrive } ).FreeSpace / 1GB
$FreeSpace = [math]::Round($Freespace,0)

If ($FreeSpace -gt $AllowedMinimumDiskFree){
    Write-Output "UPSTREAM: Available Disk: Available disk: $FreeSpace GB"
    Write-Output "UPSTREAM: Available Disk: Less than $AllowedMinimumDiskFree GB: NO"
    Write-Output "UPSTREAM: Available Disk: Is available disk compliant: YES"}

Else{
    Write-Output "UPSTREAM: Available Disk: Available disk: $FreeSpace GB`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Available Disk: Less than $AllowedMinimumDiskFree GB: YES`r" -Outvariable +AppendErrorMessage
    Write-Output "UPSTREAM: Available Disk: Is available disk compliant: NO`r" -Outvariable +AppendErrorMessage
    $IsComputerCompliant = "NO"}

# End of the line for the Compliance Thest. It's either YES or NO, nothing in between. If compliance is "NO" a custom Windows Event Set
# will be created to be used with most RMM's Event Log parsing capabilities.
# -----------------------------------------------------------------------------------------------------------------------

Write-Output "UPSTREAM: Is this computer compliant: $IsComputerCompliant"

If ($IsComputerCompliant -Match "NO"){
    Write-Output "UPSTREAM: One Windows Event Log was created for your RMM to pick up."
    $UpstreamPowerPacklogFileExists = [System.Diagnostics.EventLog]::SourceExists("UpstreamPowerPack")
        
    If ($UpstreamPowerPacklogFileExists -Match "True"){
    # UpstreamPowerPack Event Log Source exists on local machine. Nothing to do.
    }
        
    Else{
    # UpstreamPowerPack Event Log Source does not exist. Let's create.
        New-EventLog -LogName System -Source UpstreamPowerPack}

    # This line will create the Windows Event Log for your RMM to pick up.
    Write-EventLog -LogName System -Source UpstreamPowerPack -EventId 1337 -Entrytype Error -Message "UPSTREAM: Is this computer compliant: NO`r$AppendErrorMessage`rPowered by Upstream Power Pack https://en.upstream.se/powerpack"
}

$EndDateTime = Get-Date
Write-Output "UPSTREAM: Compliance test ended: $EndDateTime"
Write-Output "Powered by Upstream Power Pack https://en.upstream.se/powerpack"
