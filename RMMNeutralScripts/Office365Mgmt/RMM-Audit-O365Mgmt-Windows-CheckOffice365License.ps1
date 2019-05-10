# Script name: RMM-O365Mgmt-Windows-CheckOffice365License.ps1
# Script type: Powershell
# Script description: Check the Office 365 license information and activation status on local machine.
# Dependencies: Office 2016 and OSPP.VBS present on local machine.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------
 
# First, let's look for Office 365 on the local machine. Perticularly the OSPP.VBS file we are going to use in this script.
If(Test-Path -Path "C:\Program Files (x86)\Microsoft Office\Office16"){
    $O365LicenseInfo = cscript.exe //nologo "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" /dstatus | Out-String
}
If(Test-Path -Path "C:\Program Files\Microsoft Office\Office16"){
    $O365LicenseInfo = cscript.exe //nologo "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /dstatus | Out-String
}

# Let's write the results back to the Powershell console.
Write-Output "UPSTREAM: Detailed Office 365 license information:" $O365LicenseInfo

# Now, let's check for any license issues. Anything regarding ---NOTIFICATIONS--- would indicate something is wrong with the licensing. 
if ($O365LicenseInfo -Match "---NOTIFICATIONS---"){
	Write-Output "UPSTREAM: Whoops. There may be potential problems with Office 365 licensing. Please investigate. Additional Windows Event Log will be written for alarm generation."
	
	# This If/Else section will check if the UpstreamPowerPack Event Log source exists on local machine. We use it for error logging.
	$UpstreamPowerPacklogFileExists = [System.Diagnostics.EventLog]::SourceExists("UpstreamPowerPack");
	If ($UpstreamPowerPacklogFileExists -Match "True"){
		Write-Output "UPSTREAM: UpstreamPowerPack Event Log source exists."
	}
	Else{
		# Let's create the Event Log source om the system if missing.
		Write-Output "UPSTREAM: UpstreamPowerPack Event Log source does not exists. Creating."
		New-EventLog -LogName System -Source UpstreamPowerPack	
	}	
	
	Write-EventLog -LogName System -Source UpstreamPowerPack -EventId 10 -Entrytype Information -Message "UPSTREAM: Whoops. There may be potential problems with Office 365 licensing. Please investigate. Detailed licesne information: $($O365LicenseInfo)"
}
Else{
	Write-Output "UPSTREAM: Office 365 license(s) found, activated and looking good!"	
}
