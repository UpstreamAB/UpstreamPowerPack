# Script name: RMM-Audit-Windows-CheckOSLicense.ps1
# Script type: Powershell
# Script description: Check the Winsows OS license activation status on local machine.
# Dependencies: Windows OS.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

# This is a list of all possible license status codes. 
# 0 = Unlicensed
# 1 = Licensed
# 2 = OOB Grace
# 3 = OOT Grace
# 4 = Non-Genuine Grace
# 5 = Notification
# 6 = Extended Grace

# First, let's get the Windows OS license status back as a variable.
$LicenseStatus = (Get-CimInstance -ClassName SoftwareLicensingProduct | Where{$_.PartialProductKey -and $_.Name -Like "*Windows(R)*"} | Select -Expand LicenseStatus)

Write-Output "UPSTREAM: Windows OS license status:" $LicenseStatus

# Let's check for any license issues. If the variable $LicenseStatus is not equal to "1", then we may have a problem.
	if ($LicenseStatus -NotMatch "1"){
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
		Write-EventLog -LogName System -Source UpstreamPowerPack -EventId 10 -Entrytype Information -Message "UPSTREAM: Whoops. Windows OS license is NOT activated on this machine."
	}
	Else{
		Write-Output "UPSTREAM: Windows OS license found, activated and looking good!"	
	}
