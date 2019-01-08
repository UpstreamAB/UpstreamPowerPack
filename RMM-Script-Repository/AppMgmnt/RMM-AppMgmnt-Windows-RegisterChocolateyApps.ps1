# Script name: RMM-AppMgmnt-Windows-RegisterChocolateyApps.ps1
# Script type: Powershell
# Script description: Register local list of applications to be managed with Chocolatey by re-deploying.
# Dependencies: Powershell 3.0
# Supported OS: Windows Server 2012, Windows Server 2016, Windows Server 2019, Windows 7, Windows 10
# Script maintainer: powerpack@upstream.se
# https://www.upstream.com/powerpack
# ------------------------------------------------------------------------------------------------------------------------------

# Step 1. Check for dependecies.
#Requires -Version 3
# Let's check if Chocolatey is installed on local machine. If not, install and continue.
if (Test-Path "C:\ProgramData\Chocolatey\choco.exe")
{
	Write-Output "UPSTREAM: Great! Chocolatey is already installed on this machine. Let's continue."
}
else
{
	Write-Output "UPSTREAM: Whoops! Chocolatey is missing on this machine. Let's install and continue."
	Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Step 2. Create some variables.
# Let's get applications already managed with Chocolatey by getting a list and feed it to a varible.
$AppsCurrentlyManagedByChocolatey = C:\ProgramData\Chocolatey\choco.exe list --local-only
# Let's get installed applications from Add/Remove Programs and feed to a variable.
# 32Bit Windows apps.
$InstalledAppsFromAddRemove = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object -ExpandProperty DisplayName
# 64Bit Windows apps.
$InstalledAppsFromAddRemove += Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object -ExpandProperty DisplayName
# Let's create a list of packages we want to be managed with Chocolatey. Packages can be viewed here: https://chocolatey.org/packages.
$ChocolateyPackageName = @(
	"flashplayerppapi"
	"flashplayerplugin"
	"firefox"
	"googlechrome"
)
# Let's create a local Add/Remove app list counterpart to above packages. It's important that the rows match. For example, "firefox" and "Mozilla Firefox" should both be represented in row 3.
$LocalRegistryAppName = @(
	"Adobe Flash Player 32 PPAPI"
	"Adobe Flash Player 32 NPAPI"
	"Mozilla Firefox"
	"Google Chrome"
)
# Step 3. Make some needed preparations with running web browsers.
# If Adobe Flash Player 32 NPAPI is installed on local machine but not yet managed with Chocolatey we need to close Chrome in order to install. This is a one time thing.
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
		Write-Output "UPSTREAM: $($LocalRegistryAppName[$index]) is installed but not managed with Chocolatey package $($ChocolateyPackageName[$index]). We will re-deploy with Chocolatey right now."
		if ($InstalledAppsFromAddRemove -match $LocalRegistryAppName[$index])
		{
			Write-Output "UPSTREAM: Installing $($ChocolateyPackageName[$index]) with Chocolatey."
			C:\ProgramData\Chocolatey\choco install "$($ChocolateyPackageName[$index])" --limit-output --no-progress -y
		}
		else
		{
			Write-Output "UPSTREAM: Choco package $($ChocolateyPackageName[$index]) not installed and no local application counterpart identified."
		}
	}
}
