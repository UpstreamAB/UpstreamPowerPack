# Script name: RMM-AppMgmt-Windows-ChocoDeploy-RegisterChocoApps.ps1
# Script type: Powershell
# Script description: Register local list of applications to be managed with Chocolatey by re-deploying.
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://www.upstream.com/powerpack
# --------------------------------------------------------------------------------------------------------------------------------

#Requires -Version 3
# Let's check if Chocolatey is installed on local machine. If not, install and continue.
Write-Output "UPSTREAM: Checking for Chocolatey on this machine."
if (Test-Path "C:\ProgramData\Chocolatey\choco.exe")
{
	Write-Output "UPSTREAM: Great! Chocolatey is already installed on this machine. Let's go!"
}
else
{
	Write-Output "UPSTREAM: Whoops! Chocolatey is missing on this machine. Let's install and carry on."
	Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Let's get applications already managed with Chocolatey by getting a list and feed it to a varible.
$AppsCurrentlyManagedByChocolatey = C:\ProgramData\Chocolatey\choco.exe list --local-only
# Let's get installed applications from Add/Remove Programs and feed to a variable.
# 32Bit Windows apps.
$InstalledAppsFromAddRemove = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object DisplayName -ne $null | Select-Object -ExpandProperty DisplayName
# 64Bit Windows apps.
$InstalledAppsFromAddRemove += Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object DisplayName -ne $null | Select-Object -ExpandProperty DisplayName
# Let's create a list of packages we want to be managed with Chocolatey. Packages can be viewed here: https://chocolatey.org/packages.
$ChocolateyPackageName = @(
	"flashplayerppapi"
	"flashplayerplugin"
	"firefox"
	"googlechrome"
	"adobereader"
	"adobeair"
	"jre8"
	"7zip"
)
# Let's create a local Add/Remove app list as counterpart to above packages. It's important that the rows match. For example, "firefox" and "Mozilla Firefox" should be both bre represented in row 3.'
$LocalRegistryAppName = @(
	"Adobe Flash Player 32 PPAPI"
	"Adobe Flash Player 32 NPAPI"
	"Mozilla Firefox"
	"Google Chrome"
	"Adobe Acrobat Reader DC"
	"Adobe AIR"
	"Java 8 update"
	"7-Zip"
)

# If any local Add/Remove app from $LocalRegistryAppName above are missing in $ChocolateyPackageName we will re-deploy the app with Chocolatey in order for it to register.
for ($index = 0; $index -lt $ChocolateyPackageName.length; $index++)
{
	if ($AppsCurrentlyManagedByChocolatey -Match $ChocolateyPackageName[$index])
	{
		Write-Output "UPSTREAM: $($LocalRegistryAppName[$index]) is installed and managed by Choco Package $($ChocolateyPackageName[$index])."
	}
	else
	{
		if ($InstalledAppsFromAddRemove -Match $LocalRegistryAppName[$index])
		{
			Write-Output "UPSTREAM: $($LocalRegistryAppName[$index]) is installed but not managed with Choco Package $($ChocolateyPackageName[$index]). We need to re-deploy with Chocolatey."
			C:\ProgramData\Chocolatey\choco.exe install "$($ChocolateyPackageName[$index])" --limit-output --no-progress -y
		}
	}
}
