<#	
	===========================================================================
		Filename:     	RMM-AppMgmt-Windows-UninstallChrome.ps1
		Latest update:  2019-01-19
		Created by:   	powerpack@upstream.se
		Organization: 	Upstream AB, https://en.upstream.se/powerpack
	===========================================================================
	.DESCRIPTION
		Uses the Uninstall to remove Google Chrome from local machine silently. Reports back success or 
		failure based on Add/Remove programs list.
	.NOTES
		First release.
#>

# What application do you want to uninstall? Use the name from the Add/Remove Control Panel.
$AppName = "Google Chrome"
# What is the process name of the application. If running it will be stopped.
$AppProcessName = "chrome"

Write-Output "UPSTREAM: Executing script to remove:" $AppName

# Let's get the application as a variable if installed on local machine.
$AppRemove = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "$AppName" }

# If the $AppRemove vairable matches the $AppName we are looking for, let's move on.
if ($AppRemove -Match $AppName)
{
	# Let's be sure the application is isn't running before we start the uninstall.
	Write-Output "UPSTREAM: Application found and will be stopped if running. Attempting to uninstall."
	Get-Process | Where { $_.Name -match "$AppProcessName" } | Stop-Process -Force
	$AppRemove.Uninstall()
	
	# Let's test again if the application still is present on the local machine. We don't want that.
	$IsAppRemovedOrNot = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "$AppName" }
	if ($IsAppRemovedOrNot -Match $AppName)
	{
		Write-Output "UPSTREAM: Application failed to uninstall. Evaluate the Application Event Log."
	}
	else
	{
		Write-Output "UPSTREAM: Application successfully uninstalled."
	}
}
else
{
	Write-Output "UPSTREAM: Application not found. Nothing to do."
}
