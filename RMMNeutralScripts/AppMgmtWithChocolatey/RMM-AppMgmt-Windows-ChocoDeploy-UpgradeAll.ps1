# Script name: RMM-AppMgmt-Windows-ChocoDeploy-UpgradeAll.ps1
# Script type: Powershell
# Script description: Upgrade all Choco deployed apps on local machine.
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
	Write-Output "UPSTREAM: Whoops! Chocolatey is missing on this machine. Installing, but not much will happen here. You have to deploy apps with Choco in order to upgrade with Choco."
	Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
c:\ProgramData\Chocolatey\choco.exe upgrade all --limit-output --no-progress -y
