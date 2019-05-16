# Script name: RMM-Audit-O365Mgmt-Windows-CheckOffice365License.ps1
# Script type: Powershell
# Script description: Check the Office 365 license information and activation status on local machine.
# Dependencies: Office 2016 and OSPP.VBS present on local machine.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------
 
# First, let's look for Office 365 on the local machine. Particularly the OSPP.VBS file that we are going to use in this script.
If(Test-Path -Path "C:\Program Files (x86)\Microsoft Office\Office16"){
    $O365LicenseInfo = cscript.exe //nologo "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" /dstatus | Out-String
}

If(Test-Path -Path "C:\Program Files\Microsoft Office\Office16"){
    $O365LicenseInfo = cscript.exe //nologo "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /dstatus | Out-String
}

# This If/Else section will determine if we got anything back from the $O365LicenseInfo variable above and act on that.
If ($O365LicenseInfo -Match "Processing"){
	# Let's write the results from above back to the Powershell console.
	Write-Output "UPSTREAM: Detailed Office 365 license information:" $O365LicenseInfo

	# Now, let's check for any license issues. Anything regarding "---NOTIFICATIONS---" would indicate something is wrong. 
	if ($O365LicenseInfo -Match "---NOTIFICATIONS---"){
		Write-Output "UPSTREAM: Whoops. There may be potential problems with Office 365 licensing. Please investigate. Additional Windows Event Log will be created for your RMM to pick up."
		
		# This If/Else section will check if the UpstreamPowerPack Event Log Source exists on local machine. We use it to create alarms based on most RMM's Event Log parsing capabilities.
		$UpstreamPowerPacklogFileExists = [System.Diagnostics.EventLog]::SourceExists("UpstreamPowerPack");
		If ($UpstreamPowerPacklogFileExists -Match "True"){
			# Great. UpstreamPowerPack Event Log Source exists on local machine. Probably created from anoter of our scripts."
		}
		Else{
			# UpstreamPowerPack Event Log Source does not exist. Let's create.
			New-EventLog -LogName System -Source UpstreamPowerPack	
		}	
		# This line will create the Windows Event Log for your RMM to pick up.
		Write-EventLog -LogName System -Source UpstreamPowerPack -EventId 10 -Entrytype Information -Message "UPSTREAM: Whoops. There may be potential problems with Office 365 licensing. Please investigate. Detailed licesne information: $($O365LicenseInfo)"
	}
	Else{
		Write-Output "UPSTREAM: Office 365 license(s) found, activated and looking good!"	
	}
}
Else{
	Write-Output "UPSTREAM: We can't find OSPP.VBS on this machine. Nothing to do."
}
