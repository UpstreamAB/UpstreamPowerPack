# Script name: RMM-Audit-Win10-ComputerComplianceTest.ps1
# Script type: Powershell
# Script description: A computer compliance test to be used for pro-actively catch and address problems.
# Dependencies: Windows 10, PSWINUpate module
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------


# Windows Update test
# What is the allowed number of missing patches?
$AllowedNumberOfMissingPatches = "3"

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
$NumberOfDaysBackLookingForUnexpectedShutdowns = "7"
$AllowedNumberOfUnexpectedShutdowns = "3"

# Applciation Error & Hangs test
$NumberOfDaysBackLookingForApplicationErrors = "7"
$AllowedNumberOfapplicationErrors = "5"

# Avialable Disk test
$AllowedMinimumDiskFree = "20"

# -----------------------------------------------------------------------------------------------------------------------
$StartDate = (Get-Date)
Write-Output "UPSTREAM: Compliance Check: Started $StartDate"

# At script start the variable $IsComputerCompliant is always "YES".
$IsComputerCompliant = "YES"

# Checking if PSWinUpdate Powershell module from PSGallery is instatalled on this machine. We need this to test Windows Updates.

Write-Output "UPSTREAM: Compliance Check: Checking for PSWinUpdate Powershell module."
If(-not(Get-InstalledModule PSWinUpdate -ErrorAction silentlycontinue)){
    Write-Output "UPSTREAM: Compliance Check: Installing PSWinUpdate Powershell module..."
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module PSWinUpdate -AllowClobber -Confirm:$False -Force
    Import-Module PSWinUpdate -ErrorAction Stop}

Else{
    Write-Output "UPSTREAM: Compliance Check: PSWinUpdate Powershell module already istalled. Continuing."}

# Test: Check Windows Update status
# -----------------------------------------------------------------------------------------------------------------------

Write-Output "UPSTREAM: Compliance Check: Windows Update: Scanning for missing Windows Updates."

$updates = Get-WuInstall
$updatenumber = ($updates.kb).count

Write-Output "UPSTREAM: Compliance Check: Windows Update: Number of missing Windows Updates: $updatenumber"

# Ok, here comes the logic. If this computer are missing more than $AllowedNumberOfMissingPatches Windows Updates the compliance will be set to NO.
If ($updatenumber -gt $AllowedNumberOfMissingPatches){
    Write-Output "UPSTREAM: Compliance Check: Windows Update: Missing more than $AllowedNumberOfMissingPatches Windows Updates: YES"
    Write-Output "UPSTREAM: Compliance Check: Windows Update: Is Windows Update compliant: NO"
    Write-Output $updates
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Compliance Check: Windows Update: Missing more than $AllowedNumberOfMissingPatches Windows Updates: NO"
    Write-Output "UPSTREAM: Compliance Check: Windows Update: Is Windows Update compliant: YES"
    $IsComputerCompliant = "YES"}

# Test: Check Windows Firewall status
# -----------------------------------------------------------------------------------------------------------------------
$FirewallStatus = 0
$SysFirewallReg1 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg1 -eq 1){
    Write-Output "UPSTREAM: Compliance Check: Windows Firewall: Domain Profile enabled: YES"
    $FirewallStatus = 1}

Else{
    Write-Output "UPSTREAM: Compliance Check: Windows Firewall: Domain Profile enabled: NO"}

$SysFirewallReg2 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg2 -eq 1){
    Write-Output "UPSTREAM: Compliance Check: Windows Firewall: Public Profile enabled: YES"
    $FirewallStatus = ($FirewallStatus + 1)}

Else{
    Write-Output "UPSTREAM: Compliance Check: Windows Firewall: Public Profile enabled: NO"}


$SysFirewallReg3 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" -Name EnableFirewall | Select-Object -ExpandProperty EnableFirewall
If ($SysFirewallReg3 -eq 1){
    $FirewallStatus = ($FirewallStatus + 1)
    Write-Output "UPSTREAM: Compliance Check: Windows Firewall: Standard Profile enabled: YES"}

Else{
    Write-Output "UPSTREAM: Compliance Check: Windows Firewall: Standard Profile enabled: NO"}

# Ok, here comes the logic. If any of the profiles above are disabled the compliance will be set to NO.
If ($FirewallStatus -eq 3){
    Write-Output "UPSTREAM: Compliance Check: Windows Firewall: Is Windows Firewall compliant: YES"}

Else{
    Write-Output "UPSTREAM: Compliance Check: Windows Firewall: Is Windows Firewall compliant: NO"
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
    Write-Output "UPSTREAM: Compliance Check: Anti-Virus: Real-time protection enabled: YES"} 

Else{
    Write-Output "UPSTREAM: Compliance Check: Anti-Virus: Real-time protection enabled: NO"
    $IsComputerCompliant = "NO"}

# Ok, here comes the logic. If this computer are reporting $AVDefinitionStatus as anything else than "Up to date" the compliance will be set to NO.
If ($AVDefinitionStatus -Match "Up to date"){
    Write-Output "UPSTREAM: Compliance Check: Anti-Virus: Definition up to date: YES"}

Else{
    Write-Output "UPSTREAM: Compliance Check: Anti-Virus: Definition up to date: NO"
    $IsComputerCompliant = "NO"}

# Ok, here comes the logic. If this computer are reporting $AVRealTimeProtectionStatus OR as $AVDefinitionStatus as "NO" the the whole Anti-Virus compliance test will be set to NO.
If ($AVRealTimeProtectionStatus -Match "NO" -Or $AVDefinitionStatus -Match "NO"){
    Write-Output "UPSTREAM: Compliance Check: Anti-Virus: Is Anti-Virus compliant: NO"
    Get-AntiVirusProduct}

Else{
    Write-Output "UPSTREAM: Compliance Check: Anti-Virus: Is Anti-Virus compliant: YES"}

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

Write-Output "UPSTREAM: Compliance Check: Windows Reboot: Last reboot was $LastRebootInDays days ago."

# Ok, here comes the logic. If this computer have more than $AllowedNumberOfDaysWithoutReboot days of Reboot compliance will be set to NO.
If ($LastRebootInDays -gt $AllowedNumberOfDaysWithoutReboot){
    Write-Output "UPSTREAM: Compliance Check: Windows Reboot: Last reboot more than $AllowedNumberOfDaysWithoutReboot ago: YES"
    Write-Output "UPSTREAM: Compliance Check: Windows Reboot: Is Windows Reboot compliant: NO"
    $IsComputerCompliant = "NO"}

Else{
    Write-Output "UPSTREAM: Compliance Check: Windows Reboot: Reboot more than $AllowedNumberOfDaysWithoutReboot days: NO"
    Write-Output "UPSTREAM: Compliance Check: Windows Reboot: Is Windows last reboot compliant: YES"}


# Test: Unexpected shutdowns in the Windows Event Log.
# -----------------------------------------------------------------------------------------------------------------------
$UnexpectedShutdownEvents = Get-EventLog -LogName System -EntryType Error -After ([DateTime]::Today.AddDays(-$NumberOfDaysBackLookingForUnexpectedShutdowns))| Where-Object {$_.EventID -eq 6008}
$NumberOfUnexpectedShutdowns = ($UnexpectedShutdownEvents.EventID).count
Write-Output "UPSTREAM: Compliance Check: Unexpected Shutdowns: Detected shutdowns whitin $NumberOfDaysBackLookingForUnexpectedShutdowns days: $NumberOfUnexpectedShutdowns"

If ($NumberOfUnexpectedShutdowns -gt $AllowedNumberOfUnexpectedShutdowns){
    Write-Output "UPSTREAM: Compliance Check: Unexpected Shutdowns: More than $AllowedNumberOfUnexpectedShutdowns within $NumberOfDaysBackLookingForUnexpectedShutdowns days: YES"
    Write-Output "UPSTREAM: Compliance Check: Unexpected Shutdowns: Is Unexpected shutdowns compliant: NO"
    $IsComputerCompliant = "NO"
    $UnexpectedShutdownEvents}
else{
    Write-Output "UPSTREAM: Compliance Check: Unexpected Shutdowns: Shutdowns more than $AllowedNumberOfUnexpectedShutdowns within $NumberOfDaysBackLookingForUnexpectedShutdowns days: NO"}
    Write-Output "UPSTREAM: Compliance Check: Unexpected Shutdowns: Is Unexpected shutdowns compliant: YES"

# Test: Application hangs and errors in the Windows Event Log.
# -----------------------------------------------------------------------------------------------------------------------
$ApplicationErrorEvents = Get-EventLog -LogName Application -EntryType Error -After ([DateTime]::Today.AddDays(-$NumberOfDaysBackLookingForApplicationErrors))| Where-Object {$_.EventID -eq 1000 -or $_.EventID -eq 1002}
$NumberApplicationErrorEvents = ($ApplicationErrorEvents.EventID).count
Write-Output "UPSTREAM: Compliance Check: Number of application errors detected within $NumberOfDaysBackLookingForApplicationErrors days: $NumberApplicationErrorEvents"

If ($NumberApplicationErrorEvents -gt $AllowedNumberOfapplicationErrors){
    Write-Output "UPSTREAM: Compliance Check: Application Errors: More than $AllowedNumberOfapplicationErrors whitin $NumberOfDaysBackLookingForApplicationErrors days: YES"
    Write-Output "UPSTREAM: Compliance Check: Application Errors: Is Application errors compliant: NO"
    $IsComputerCompliant = "NO"
    $ApplicationErrorEvents}
else{
    Write-Output "UPSTREAM: Compliance Check: Application Errors: More than $AllowedNumberOfapplicationErrors within $NumberOfDaysBackLookingForApplicationErrors days: NO"}
    Write-Output "UPSTREAM: Compliance Check: Application Errors: Is Application errors compliant: YES"

# Test: Available disk on system drive.
# -----------------------------------------------------------------------------------------------------------------------
$FreeSpace = ( Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $env:SystemDrive } ).FreeSpace / 1GB
$FreeSpace = [math]::Round($Freespace,0)
Write-Output "UPSTREAM: Compliance Check: Available Disk: Available disk: $FreeSpace GB"

If ($FreeSpace -gt $AllowedMinimumDiskFree){
    Write-Output "UPSTREAM: Compliance Check: Available Disk: Less than $AllowedMinimumDiskFree GB: NO"
    Write-Output "UPSTREAM: Compliance Check: Available Disk: Is available disk compliant: YES"}
else{
    Write-Output "UPSTREAM: Compliance Check: Available Disk: Less than $AllowedMinimumDiskFree GB: YES"
    Write-Output "UPSTREAM: Compliance Check: Available Disk: Is available disk compliant: NO"
    $IsComputerCompliant = "NO"}

# End of the line: Compliance Check. It's either YES or NO, nothing in between.
# -----------------------------------------------------------------------------------------------------------------------
$EndDate = (Get-Date)
Write-Output "UPSTREAM: Compliance Check: Is this computer compliant: $IsComputerCompliant"
Write-Output "UPSTREAM: Compliance Check: Ended $EndDate"
Write-Output "Compliance Check powered by Upstream Powwer Pack https://en.upstream.se/powerpack"
