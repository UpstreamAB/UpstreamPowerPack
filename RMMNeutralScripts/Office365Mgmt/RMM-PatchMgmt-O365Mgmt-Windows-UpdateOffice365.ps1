# Script name: RMM-PatchMgmt-O365Mgmt-Windows-UpdateOffice365.ps1
# Script type: Powershell
# Script description: Updadates existing Office 365 installation with the latest patches.
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

$OfficeC2RClient = "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
$Arguments = "/update user updatepromptuser=true forceappshutdown=true displaylevel=true"
Start-Process $OfficeC2RClient $Arguments