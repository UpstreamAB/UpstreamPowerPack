<#
=================================================================================
Pulseway script    Audit: Security: Scan For Log4Shell
Support type       Upstream Pulseway Power Pack
Support            Upstream AB, powerpack@upstream.se
Lastest version    v1.1 2021-12-18
=================================================================================

Full documentation: https://upstream.eu.itglue.com/1387150/docs/2453120028147926 (incognito)

Release notes
v1.1 2022-12-18
- Moved to the new zip version of the scanner removing the need for 7zip Powershell module.
- Updated the download path to logpresso-log4j2-scan-2.2.0-win64.zip (lates when writing).
- Added new logic to detect if Log4ShellScan.txt does not exist after scan.
- Added a Windows event log entry if Log4ShellScan.txt does not exist resulting in a Pulsway notification if the scanner fails to execute.

v1.0 2022-12-16
First version

.DESCRIPTION
This Powershell script will execute a Log4Shell scan with the help of Lopgresso. If the scan detects vilnerable JAR files a 
Windows Event Log will be created for Pulseway RMM to pick up and generate alert upon. If you get VCRUNTIME140.dll not found
error, install Visual C++ Redistributable.
#>

# -----------------------------------------------------------------------------------------------------------------------
# VARIABLES & OPTIONS

# The scanner we use is downloaded from here: "https://github.com/logpresso/CVE-2021-44228-Scanner".
# Keep in mind that the scanner may get updated frequently with new download path.
$Url = "https://github.com/logpresso/CVE-2021-44228-Scanner/releases/download/v2.2.0/logpresso-log4j2-scan-2.2.0-win64.zip"

# Let's agree on the Log4Shell folder, Zip filename, extraxted EXE filename and log file. You probably don't need to change this.
$Folder = "C:\Log4ShellScan"
$File = "$Folder\log4j2-scan.zip"
$Scanner = "$Folder\log4j2-scan.exe"
$ScanLog = "$Folder\Log4ShellScan.txt"

# The method for downloading the file.
$WebClient = New-Object System.Net.WebClient

# END OF VARIABLES & OPTIONS
# -----------------------------------------------------------------------------------------------------------------------

# Checking for download Folder. Create if missing.
If (-not (Test-Path -LiteralPath $Folder)) {
    Write-Output "UPSTREAM: Log4Shell: Preparations: $Folder Does Not Exists. Creating." 
    New-Item -Path "$Folder" -ItemType Directory >$Null }

Else {
    Write-Output "UPSTREAM: Log4Shell: Preparations: $Folder Exists." }


# Checking for Upstream's custom Event source. Create if missing.
$UpstreamPowerPacklogFileExists = [System.Diagnostics.EventLog]::SourceExists("UpstreamPowerPack")
    
If ($UpstreamPowerPacklogFileExists -Match "True") {
    Write-Output "UPSTREAM: Log4Shell: Preparations: UpstreamPowerPack Event Log Source exist." }
                  
Else {
    # UpstreamPowerPack Event Log Source does not exist. Let's create.
    Write-Output "UPSTREAM: Log4Shell: Preparations: UpstreamPowerPack Event Log Source does not exist. Let's create."
    New-EventLog -LogName System -Source UpstreamPowerPack }


# Download and extraxt the Logpresso Log4Shell Scanner.
Write-Output "UPSTREAM: Log4Shell: Preparations: Downloading the installer from $Url."
$WebClient.DownloadFile($Url, $File)
Expand-Archive -Path $File -DestinationPath $Folder


# Execute the Log4Shell scanner.
Write-Output "UPSTREAM: Log4Shell: Starting the Log4Shell scan. Depending on the size of the disk(s) it can take a while."
Start-Process -FilePath $Scanner -Wait -NoNewWindow -ArgumentList "--all-drives --scan-zip --silent" -RedirectStandardOutput $ScanLog


# Evaluate the result from scan.
If(Get-Item -Path $ScanLog -ErrorAction Ignore) {
    Write-Output "UPSTREAM: Log4Shell: Scan results: $ScanLog exists." 
    # Get the scan results back to a variable.
    $ScanResult = Get-Content $Scanlog
    Write-Output "UPSTREAM: Log4Shell: Scan results:`n$ScanResult"

    If ($ScanResult -Match "Found 0 vulnerable files") {
        Write-Output "UPSTREAM: No vulnerable JAR files found. No alert will be created." }

    Else {
        Write-Output "UPSTREAM: Log4Shell: Vulnerable files found, creating a custom Windows Event Log to be picked up by Pulseway RMM."
        Write-Output "UPSTREAM: Log4shell: Name: System, Type: Information, Source: UpstreamPowerPack, ID: 1337,"
        # Action: Write custom Windows Event Log if Log4Shell vulnerabilitues are found for Pulseway RMM to pick up.
        Write-EventLog -LogName System -Source UpstreamPowerPack -EventId 1337 -Entrytype Information -Message "UPSTREAM: Log4Shell Vulnerabilities found: YES`n$ScanResult`n`nPowered by Upstream Power Pack Premium (support@upstream.se), www.upstreampowerpack.com" }
}
    

Else {
    Write-Output "UPSTREAM: Log4Shell: Scan results: $ScanLog does not exist."
    # Action: Write custom Windows Event Log if Log4Shell vulnerabilitues are found for Pulseway RMM to pick up.
    Write-EventLog -LogName System -Source UpstreamPowerPack -EventId 1337 -Entrytype Information -Message "UPSTREAM: Log4Shell scan failed. $ScanLog does not exist.`nEvaluate why $Scanner could not execute. Is VCRUNTIME140.dll from Visual C++ Redistributable installed?`nPowered by Upstream Power Pack Premium (support@upstream.se), www.upstreampowerpack.com" }


Write-Output "UPSTREAM: Log4Shell: Done. Finishing up with some house cleaning."
# Removing the scanner ZIP file.
Remove-Item -Path $File -Recurse
# Removing the scanner EXE file. 
remove-Item -Path $Scanner -Recurse
# Removing the scan TXT log (disabled by default).
#Remove-Item -Path $ScanLog -Recurse
# Removing the download folder and any remaining files (disabled by default).
#Remove-Item -Path $Folder -Recurse

Write-Output "Powered by Upstream Power Pack Premium (support@upstream.se), www.upstreampowerpack.com"
