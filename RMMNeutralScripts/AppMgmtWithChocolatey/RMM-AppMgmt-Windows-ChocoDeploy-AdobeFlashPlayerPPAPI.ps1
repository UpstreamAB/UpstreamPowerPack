<#
=================================================================================
Filename:           RMM-AppMgmt-Windows-ChocoDeploy-AdobeFlashPlayerPPAPI.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-04-22
=================================================================================
#>

# Let's check if Chocolatey is installed on local machine. If not, install.
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
Write-Output "UPSTREAM: In order to install properly with Choholatey we need to close Chrome during installation if running."
Get-Process | Where-Object { $_.Name -eq "chrome" } | Select-Object -First 1 | Stop-Process
# This line will tell Chocolatey to install the Adobe Flash Player 32 PPAPI package.
c:\ProgramData\Chocolatey\choco.exe install flashplayerppapi --limit-output --no-progress -y
