# Script name: RMM-Audit-Windows-CheckOSLicenseActivation.ps1
# Script type: Powershell
# Script description: Check the Winsows OS license activation status on local machine.
# Dependencies: Windows OS.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------
 
# First, let's investigate wether the Windows OS license is activated or not. The response back is "0" for not activated and "1" for activated.
$LicenseStatus = (Get-CimInstance -ClassName SoftwareLicensingProduct | Where{$_.PartialProductKey -and $_.Name -Like "*Windows(R)*"} | Select -Expand LicenseStatus)

Write-Output "UPSTREAM: Windows OS license status:" $LicenseStatus

# Now, let's check for any license issues. If the variable $LicenseStatus is equal to "0" we have a problem.
	if ($LicenseStatus -Match "0"){
		Write-Output "UPSTREAM: Whoops. Windows OS license isn't activated. Please investigate. Additional Windows Event Log will be created for your RMM to pick up."
		
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
		Write-EventLog -LogName System -Source UpstreamPowerPack -EventId 10 -Entrytype Information -Message "UPSTREAM: Windows OS license isn't activated."
	}
	Else{
		Write-Output "UPSTREAM: Windows OS license found, activated and looking good!"	
	}
