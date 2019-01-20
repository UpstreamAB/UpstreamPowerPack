<#	
	Script name: RMM-AppMgmt-Windows-DeployChrome.ps1
	Script type: Powershell
	Script description: Deploys Google Chrome on local machine.
	Dependencies: Powershell 3.0
	Script maintainer: powerpack@upstream.se
	https://en.upstream.se/powerpack/
	
	Additional notes:
	Uses the System.Net.WebClient function fo grab the Google Chrome MSI package from URL and install
	silently with msiexec command. Reports back success or failure based on Add/Remove programs list.
#>

# What file do you want to download? Enter the path here.
$Url = "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi"
# Where do you want to put the file on the local drive?
$File = "c:\temp\googlechromestandaloneenterprise64.msi"
# What is the application name? Use the name that will be presented in the Add/Remove Control Panel.
$AppName = "Google Chrome"
# The method for downloading the file. This you do not want to change.
$WebClient = New-Object System.Net.WebClient

Write-Output "UPSTREAM: Downloading installer from" $Url "To local directory:" $File "Waiting for completion."
$WebClient.DownloadFile($Url, $File)

# Deploy the software.
Write-Output "UPSTREAM: Installation begins. Waiting for completion."
Start-Process $File /qn -Wait

# Remove the installer after completion.
#Remove-Item -Path $File -Force

# Validate successful installation by looking for $AppName in the Add/Remove Programs list. 
$IsAppInstalledOrNot = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -Match "$AppName" }

if ($IsAppInstalledOrNot -Match $AppName)
{
	Write-Output $IsAppInstalledOrNot
	Write-Output "UPSTREAM: Application successfully installed."
}
else
{
	Write-Output "UPSTREAM: Application failed to install. We can't find $AppName in the Add/Remove Programs list."
}
