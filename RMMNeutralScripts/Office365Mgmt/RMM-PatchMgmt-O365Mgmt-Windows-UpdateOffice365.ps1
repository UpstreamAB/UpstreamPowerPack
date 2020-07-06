<#
=================================================================================
Filename:           RMM-PatchMgmt-O365Mgmt-Windows-UpdateOffice365.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-04-22
=================================================================================
#>

$OfficeC2RClient = "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
$Arguments = "/update user updatepromptuser=true forceappshutdown=true displaylevel=true"
Start-Process $OfficeC2RClient $Arguments
