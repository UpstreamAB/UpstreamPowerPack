<#
=================================================================================
Filename:           UPSTREAM-PREMIUM-KaseyaVSA-PatchMgmt-Win10-RegisterChocoApps.ps1
Kaseya Procedure:   Patch Mgmt - Windows 10 - Register Apps To Be Managed By Chocolatey
Support type:       Upstream Premium Power Pack
Support:            Upstream AB, premium@upstream.se Last updated 2020-04-22
=================================================================================
#>


# --------------------------------------------------------------------------------------------------------------------------------
# VARIABLES & OPTIONS

# Let's create a list of packages we want to be managed with Chocolatey. Package names can be viewed here: https://chocolatey.org/packages.
$ChocolateyPackageName = @(
	"flashplayerppapi"
	"flashplayerplugin"
	"firefox"
	"googlechrome"
	"adobereader"
	"adobeair"
	"jre8"
	"7zip"
	"zoom"
)

# Let's create a local Add/Remove app list as counterpart to above packages. It's important that the lines match. For example, "firefox" and "Mozilla Firefox" should be both be represented in line 3.'
$LocalRegistryAppName = @(
	"Adobe Flash Player 32 PPAPI" # For Google Chrome
	"Adobe Flash Player 32 NPAPI" # For Firefox
	"Mozilla Firefox"
	"Google Chrome"
	"Adobe Acrobat Reader DC MUI"
	"Adobe AIR"
	"Java 8 update"
	"7-Zip"
	"Zoom"
)

# END OF VARIABLES & OPTIONS
# -----------------------------------------------------------------------------------------------------------------------


# Let's get applications already managed with Chocolatey by getting a list and feed it to a varible.
$AppsCurrentlyManagedByChocolatey = C:\ProgramData\Chocolatey\choco.exe list --local-only


# Let's get installed applications from Add/Remove Programs and feed to a variable.
# 32Bit Windows apps.
$InstalledAppsFromAddRemove = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object DisplayName -ne $null | Select-Object -ExpandProperty DisplayName
# 64Bit Windows apps.
$InstalledAppsFromAddRemove += Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object DisplayName -ne $null | Select-Object -ExpandProperty DisplayName

# If any local Add/Remove app from $LocalRegistryAppName above are missing in $ChocolateyPackageName we will re-deploy the app with Chocolatey in order for it to register.
For ($index = 0; $index -lt $ChocolateyPackageName.length; $index++)
{
	If ($AppsCurrentlyManagedByChocolatey -Match $ChocolateyPackageName[$index])
	{
		Write-Output "$($LocalRegistryAppName[$index]) installed and managed by Choco package $($ChocolateyPackageName[$index])."}
	
	Else{
		If ($InstalledAppsFromAddRemove -Match $LocalRegistryAppName[$index]){
			Write-Output "$($LocalRegistryAppName[$index]) installed but not managed with Choco package $($ChocolateyPackageName[$index]). Installing."
			C:\ProgramData\Chocolatey\choco.exe install "$($ChocolateyPackageName[$index])" --limit-output --no-progress -y}
	}
}
