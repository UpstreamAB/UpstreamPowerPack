# Script name: RMM-AppMgmnt-Windows-RegisterChocolateyApps.ps1
# Script type: Powershell
# Script description: Register local list of applications to be managed with Chocolatey by re-deploying.
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://www.upstream.com/powerpack
# ------------------------------------------------------------------------------------------------------------------------------

# Step 1. Check for dependecies.
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

# Step 2. Create some variables.
# Let's get applications already managed with Chocolatey by getting a list and feed it to a varible.
$AppsCurrentlyManagedByChocolatey = C:\ProgramData\Chocolatey\choco.exe list --local-only
# Let's get installed applications from Add/Remove Programs and feed to a variable.
# 32Bit Windows apps.
$InstalledAppsFromAddRemove = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName
# 64Bit Windows apps.
$InstalledAppsFromAddRemove += Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName
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
	"gotomeeting"
	"microsoft-teams"
	"skype"
	"spotify"
	"zoom"
)
# Let's create a local Add/Remove app list counterpart to above packages. It's important that the rows match. For example, "firefox" and "Mozilla Firefox" should be both bre represented in row 3.'
$LocalRegistryAppName = @(
	"Adobe Flash Player 32 PPAPI"
	"Adobe Flash Player 32 NPAPI"
	"Mozilla Firefox"
	"Google Chrome"
	"Adobe Acrobat Reader DC"
	"Adobe AIR"
	"Java 8 update"
	"7-Zip"
	"GoToMeeting"
	"Microsoft Teams"
	"Skype version"
	"Spotify"
	"Zoom"
)
# Step 3. This step evaluates the need for closing running applications.
# If Adobe Flash Player 32 NPAPI is installed on local machine but not yet managed with Chocolatey we need to close Firefox in order to install. This is a one time thing.
if ($LocalRegistryAppName["Mozilla Firefox"] -NotMatch $ChocolateyPackageName["flashplayerplugin"])
{
	Write-Output "UPSTREAM: Adobe Flash Player 32 NPAPI detected on local machine. In order to install properly with Choholatey we need to close Firefox during installation."
	Stop-Process -processname "firefox"
}
# If Adobe Flash Player 32 PPAPI is installed on local machine but not yet managed with Chocolatey we need to close Chrome in order to install. This is a one time thing.
if ($LocalRegistryAppName["Google Chrome"] -NotMatch $ChocolateyPackageName["flashplayerppapi"])
{
	Write-Output "UPSTREAM: Adobe Flash Player 32 PPAPI detected on local machine. In order to install properly with Choholatey we need to close Chrome during installation."
	Stop-Process -processname "chrome"
}
# If Skype is installed on local machine but not yet managed with Chocolatey we need to close Skype in order to install. This is a one time thing.
if ($LocalRegistryAppName["Skype"] -NotMatch $ChocolateyPackageName["skype"])
{
	Write-Output "UPSTREAM: Adobe Flash Player 32 PPAPI detected on local machine. In order to install properly with Choholatey we need to close Chrome during installation."
	Stop-Process -processname "skype"
}
# Step 4: Compare list of local apps against aproved Chocolatey apps.
# If any local Add/Remove app from $LocalRegistryAppName above are missing in $ChocolateyPackageName we will re-deploy the app with Chocolatey in order for it to register.
for ($index = 0; $index -lt $ChocolateyPackageName.length; $index++)
{
	if ($AppsCurrentlyManagedByChocolatey -match $ChocolateyPackageName[$index])
	{
		Write-Output "UPSTREAM: $($LocalRegistryAppName[$index]) is installed and already managed by Chocolatey package $($ChocolateyPackageName[$index])."
	}
	else
	{
		if ($InstalledAppsFromAddRemove -Like $LocalRegistryAppName[$index])
		{
			Write-Output "UPSTREAM: $($LocalRegistryAppName[$index]) is installed but not managed with Chocolatey package $($ChocolateyPackageName[$index]). We will re-deploy with Chocolatey right now."
			C:\ProgramData\Chocolatey\choco install "$($ChocolateyPackageName[$index])" --limit-output --no-progress -y
		}
		
	}
}
