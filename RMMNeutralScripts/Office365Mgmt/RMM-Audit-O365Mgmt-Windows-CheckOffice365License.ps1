# Script name: RMM-Audit-O365Mgmt-Windows-CheckOffice365License.ps1
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

Write-Output "UPSTREAM: Detailed Office 365 license information:" $O365LicenseInfo
 
if ($O365LicenseInfo -Match "---LICENSED---")
{
	Write-Output "UPSTREAM: Office 365 license(s) found, activated and are good to go!"
}
else
{
	Write-Output "UPSTREAM: Whoops. There may be potential problems with Office 365 licensing. Please investigate."
}
