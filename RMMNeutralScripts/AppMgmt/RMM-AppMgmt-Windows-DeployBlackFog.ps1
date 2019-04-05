# Script name: RMM-AppMgmt-Windows-DeployBlackFog.ps1
# Script type: Powershell
# Script description: Installs BlackFog Agent on local machine.
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

# What file do you want to download? Enter the path here.
$Url = "https://s3.amazonaws.com/blackfog.downloads.us/BlackFogPrivacyInstall.msi"
# Where do you want to put the file on the local disk?
$File = "c:\temp\BlackFogPrivacyInstall.msi"
# What is the application name? This is for validating installation. Use the exact name that will be presented in the Add/Remove Control Panel.
$AppName = "BlackFog Privacy"
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
