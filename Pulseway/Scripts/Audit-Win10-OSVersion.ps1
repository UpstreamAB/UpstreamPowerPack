<#
=================================================================================
Pulseway script:    Audit: Win10: OS Version
Support type:       Upstream Pulseway Power Free
Support:            Upstream AB, powerpack@upstream.se
Lastest version:    2020-10-28

Required variable inputs:
None

Required variable outputs:
Name: OutputWin10Version
Default Value: "Not Available
Associated Custom Field: "OS: Win10: Version"
=================================================================================
#>

# Current Windows 10 version
$OutputWin10Version = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId).ReleaseId
Write-Output "UPSTREAM: Extended Audit: Windows 10 Version: Current: $OutputWin10Version"

# Windows 10 upgrade history
$AllBuilds = $(gci "HKLM:\System\Setup" | ? {$_.Name -match "\\Source\s"}) | % { $_ | Select @{n="UpdateTime";e={if ($_.Name -match "Updated\son\s(\d{1,2}\/\d{1,2}\/\d{4}\s\d{2}:\d{2}:\d{2})\)$") {[dateTime]::Parse($Matches[1],([Globalization.CultureInfo]::CreateSpecificCulture('*')))}}}, @{n="ReleaseID";e={$_.GetValue("ReleaseID")}},@{n="Branch";e={$_.GetValue("BuildBranch")}},@{n="Build";e={$_.GetValue("CurrentBuild")}},@{n="ProductName";e={$_.GetValue("ProductName")}},@{n="InstallTime";e={[datetime]::FromFileTime($_.GetValue("InstallTime"))}}}
Write-Output "UPSTREAM: Extended Audit: Windows 10 Version: Upgrade History:"
Write-Output $AllBuilds | Sort UpdateTime | ft UpdateTime, ReleaseID, ProductName

Start-Process -FilePath "$env:PWY_HOME\CLI.exe" -ArgumentList ("setVariable OutputWin10Version $OutputWin10Version") -Wait
