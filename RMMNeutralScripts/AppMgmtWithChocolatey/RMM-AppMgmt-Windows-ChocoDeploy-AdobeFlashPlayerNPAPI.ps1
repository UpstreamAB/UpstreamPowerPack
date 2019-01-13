# Script name: RMM-AppMgmt-Windows-ChocoDeploy-AdobeFlashPlayerNPAPI.ps1
# Script type: Powershell
# Script description: Installs Adobe Flash Player 32 NPAPI for Firefox, Opera, Safari among other web browsers on local machine.
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
Write-Output "UPSTREAM: In order to install properly with Choholatey we need to close Chrome during installation if running."
Get-Process | Where-Object { $_.Name -eq "firefox" } | Select-Object -First 1 | Stop-Process
# This line will tell Chocolatey to install the Adobe Flash Player 32 NPAPI package.
c:\ProgramData\Chocolatey\choco.exe install flashplayerplugin --limit-output --no-progress -y
