# Script name: RMM-O365Mgmt-Windows-CheckOffice365License.ps1
# Script type: Powershell
# Script description: Check the Office 365 license information and activation on local machine.
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------
 
if(Test-Path -Path "C:\Program Files (x86)\Microsoft Office\Office16"){
    $O365LicenseInfo = cscript.exe //nologo "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" /dstatus | Out-String
}
if(Test-Path -Path "C:\Program Files\Microsoft Office\Office16"){
    $O365LicenseInfo = cscript.exe //nologo "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /dstatus | Out-String
}
 
if ($O365LicenseInfo -Match "---LICENSED---")
{
	Write-Output "UPSTREAM: Office 365 license found, activated and are good to go!"
}
else
{
	Write-Output "UPSTREAM: Whoops. There may be potential problems with Office 365 licensing. Please investigate."
}
