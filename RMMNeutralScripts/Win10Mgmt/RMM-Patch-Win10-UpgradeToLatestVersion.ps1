<#
=================================================================================
Pulseway script:    RMM-Patch-Win10-UpgradeToLatestVersion.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2021-06-18
=================================================================================
#>

# -----------------------------------------------------------------------------------------------------------------------
# VARIABLES & OPTIONS

# What is the current Windwos 10 version?
$LatestWin10Version = "21H1"

# Minimum disk allowed in GB
$MinimumDiskSpaceAllowed = "20"

# File download
$Dir = "c:\Win10Upgrade"
$WebClient = New-Object System.Net.WebClient
$Url = "https://go.microsoft.com/fwlink/?LinkId=691209"
$File = "$($dir)\Win10Upgrade.exe"

# END OF VARIABLES & OPTIONS
# -----------------------------------------------------------------------------------------------------------------------

# STANDARD PREPARATIONS
# -----------------------------------------------------------------------------------------------------------------------

# At script start the variable $IsThisComputerReadyForUpgrade is always "YES". If any tests below fails it will be set to "NO".
$IsThisComputerReadyForUpgrade = "YES"

# END OF STANDARD PREPARATIONS
# -----------------------------------------------------------------------------------------------------------------------

# Test: Available disk space on this computer
# -----------------------------------------------------------------------------------------------------------------------

$FreeSpace = (Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $env:SystemDrive }).FreeSpace / 1GB
$FreeSpace = [math]::Round($Freespace,0)
Write-Output "UPSTREAM: Win10 upgrade: Available disk space: $FreeSpace GB"
Write-Output "UPSTREAM: Win10 upgrade: Mininum available disk space allowed: $MinimumDiskSpaceAllowed GB"

If ($FreeSpace -gt $MinimumDiskSpaceAllowed){
    Write-Output "UPSTREAM: Win10 upgrade: There is enough disk available for upgrade."}

Else{
    Write-Output "UPSTREAM: Win10 upgrade: There is not enough disk space available for upgrade."
    $IsThisComputerReadyForUpgrade = "NO"}


# Test: Current Windows 10 version on this computer
# -----------------------------------------------------------------------------------------------------------------------

# This is for getting Windows 10 version 2009 and older.
If (!(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).ReleaseID) {
    Write-Output "ReleaseID registry key not found." } 
    
Else { $CurrentWin10VersionOnThisComputer = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).ReleaseID }
    
# This is for gettting Windows 10 version 20H1 an newer.
If (!(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion) {
    Write-Output "DisplayVersion registry key not found." }
    
    Else { $CurrentWin10VersionOnThisComputer = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion }
  
Write-Output "UPSTREAM: Win10 upgrade: Oldest Windows 10 version allowed: $LatestWin10Version"
Write-Output "UPSTREAM: Win10 upgrade: Windows 10 version on this computer: $CurrentWin10VersionOnThisComputer"

$CurrentWin10VersionOnThisComputer
$LatestWin10Version

If ($CurrentWin10VersionOnThisComputer -Match "$LatestWin10Version") {
    Write-Output "UPSTREAM: Win10 upgrade: No upgrade needed."
    $IsThisComputerReadyForUpgrade = "NO" }

Else { Write-Output "UPSTREAM: Win10 upgrade: Upgrade needed." }


# Execution: Upgrade Windows 10 if above tests passed
# -----------------------------------------------------------------------------------------------------------------------

If ($IsThisComputerReadyForUpgrade -Match "YES"){
    Write-Output "UPSTREAM: Win10 upgrade: This computer is ready for upgrade."
    
    If ((Test-Path -Path "$Dir") -NotMatch "True"){
        mkdir $Dir}

    Write-Output "UPSTREAM: Win10 upgrade: Downloading from path: $Url"
    Write-Output "UPSTREAM: Win10 upgrade: Downloading to path: $File"
    $WebClient.DownloadFile($Url,$File) >$Null

    Write-Output "UPSTREAM: Win10 upgrade: Executing upgrade. This may take up to 2 hours to complete."
    Start-Process -FilePath $File -ArgumentList "/quietinstall /skipeula /auto upgrade /copylogs $Dir" -Verb Runas
}

Else { Write-Output "UPSTREAM: Win10 upgrade: This computer will not get upgraded. Review the script log." }
