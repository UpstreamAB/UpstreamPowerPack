# Script name: RMM-SysMgmt-Windows-ChocoDeploy-BCUninstaller.ps1
# Script type: Powershell
# Script description: Installs BC Uninstaller tool for application removal, troubleshooting and system cleanup.
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

#Requires -Version 3
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
# This line will tell Chocolatey to install the BC Uninstaller package.
c:\ProgramData\Chocolatey\choco.exe install bulk-crap-uninstaller --limit-output --no-progress -y