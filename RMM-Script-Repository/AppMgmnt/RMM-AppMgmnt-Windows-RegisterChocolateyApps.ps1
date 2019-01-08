#Requires -Version 3

# Check if Chocolatey is installed on local machine. If not, let's install.
if (Test-Path "C:\ProgramData\Chocolatey\choco.exe")
{
	Write-Output "UPSTREAM: Great! Chocolatey is already installed on this machine. Let's continue."
}
else
{
	Write-Output "UPSTREAM: Whoops! Chocolatey not installed on this machine. Let's install and continue."
	Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Let's get applications already managed with Chocolatey by getting a list and feed it to a varible.
$AppsCurrentlyManagedByChocolatey = C:\ProgramData\Chocolatey\choco.exe list --local-only

# Let's get installed applications from Add/Remove Programs to a variable.
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
# Let's create a local Add/Remove app list counterpart to above packages. It's important that the rows match. For example, "firefox" and "Mozilla Firefoz" should be both bre represented in row 3.'
$LocalRegistryAppName = @(
	"Adobe Flash Player 32 PPAPI"
	"Adobe Flash Player 32 NPAPI"
	"Mozilla Firefox"
	"Google Chrome"
)

# If Adobe Flash Player 32 NPAPI is installed on local machine but not yet managed with Chocolatey, we need to close Chrome in order to install. This is a one time thing.
if ($LocalRegistryAppName["Mozilla Firefox"] -NotMatch $ChocolateyPackageName["flashplayerplugin"])
{
	Write-Output "UPSTREAM: Adobe Flash Player 32 NPAPI detected on local machine. In order to install properly with Choholatey we need to close Firefox during installation."
	Stop-Process -processname "firefox"
}

# If Adobe Flash Player 32 PPAPI is installed on local machine but not yet managed with Chocolatey, we need to close Chrome in order to install. This is a one time thing.
if ($LocalRegistryAppName["Google Chrome"] -NotMatch $ChocolateyPackageName["flashplayerppapi"])
{
	Write-Output "UPSTREAM: Adobe Flash Player 32 PPAPI detected on local machine. In order to install properly with Choholatey we need to close Chrome during installation."
	Stop-Process -processname "chrome"
}

# If any local Add/Remove app from $LocalRegistryAppName above are missing in $ChocolateyPackageName we will re-deploy the app with Chocolatey in order for it to register.
for ($index = 0; $index -lt $ChocolateyPackageName.length; $index++)
{
	if ($AppsCurrentlyManagedByChocolatey -match $ChocolateyPackageName[$index])
	{
		Write-Output "UPSTREAM: Choco package $($ChocolateyPackageName[$index]) is already managed by Chocolatey."
	}
	else
	{
		Write-Output "UPSTREAM: Choco package name $($ChocolateyPackageName[$index]) is installed on machine but not managed by Chocolatey. We will re-deploy with chocolatey right now."
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
