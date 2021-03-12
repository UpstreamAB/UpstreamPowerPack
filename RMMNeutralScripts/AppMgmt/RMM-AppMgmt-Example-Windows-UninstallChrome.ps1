# Script name: RMM-AppMgmt-Windows-UninstallChrome.ps1
# Script type: Powershell
# Script description: Uninstalls Google Chrome on local machine.
# Script maintainer: powerpack@upstream.se
# --------------------------------------------------------------------------------------------------------------------------------

# What application do you want to uninstall? Use the name from the Add/Remove Control Panel.
$AppName = "Google Chrome"
# What is the process name of the application. If running it will be stopped.
$AppProcessName = "chrome"

Write-Output "UPSTREAM: Executing script to remove:" $AppName

# Let's get the application as a variable if installed on local machine.
$AppRemove = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "$AppName" }

# If the $AppRemove vairable matches the $AppName we are looking for, let's move on.
If ($AppRemove -Match $AppName){
	# Let's be sure the application is isn't running before we start the uninstall.
	Write-Output "UPSTREAM: Application found and will be stopped if running. Attempting to uninstall."
	Get-Process | Where { $_.Name -match "$AppProcessName" } | Stop-Process -Force
	$AppRemove.Uninstall()
	
	# Let's test again if the application still is present on the local machine. We don't want that.
	$IsAppRemovedOrNot = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "$AppName" }
	If ($IsAppRemovedOrNot -Match $AppName){
		Write-Output "UPSTREAM: Application failed to uninstall. Evaluate the Application Event Log."}
	Else{
		Write-Output "UPSTREAM: Application successfully uninstalled."}
}

Else{
	# The application to be uninstalled isn't installed in the first place.
	Write-Output "UPSTREAM: Application not found. Nothing to do."}
