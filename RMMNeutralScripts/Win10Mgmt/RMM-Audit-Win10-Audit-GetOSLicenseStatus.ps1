<#
=================================================================================
Filename:           RMM-Audit-Win10-Audit-GetOSLicenseStatus.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-07-06
=================================================================================

This is a list of all possible license status codes. 
0 = Unlicensed
1 = Licensed
2 = OOB Grace
3 = OOT Grace
4 = Non-Genuine Grace
5 = Notification
6 = Extended Grace
#>

$LicenseStatus = (Get-CimInstance -ClassName SoftwareLicensingProduct | Where {$_.PartialProductKey -And $_.Name -Like '*Windows(R)*'} | Select-Object -Expand LicenseStatus)

If ($LicenseStatus -eq "0"){
    Write-Output "UPSTREAM: Extended Audit: OS License Status: Unlicensed"}

If ($LicenseStatus -eq "1"){
    Write-Output "UPSTREAM: Extended Audit: OS License Status: Licensed"}

If ($LicenseStatus -eq "2"){
    Write-Output "UPSTREAM: Extended Audit: OS License Status: OOB Grace"}

If ($LicenseStatus -eq "3"){
    Write-Output "UPSTREAM: Extended Audit: OS License Status: OOT Grace"}        

If ($LicenseStatus -eq "4"){
    Write-Output "UPSTREAM: Extended Audit: OS License Status: Non-Genuine Grace"}

If ($LicenseStatus -eq "5"){
    Write-Output "UPSTREAM: Extended Audit: OS License Status: Notification"}

If ($LicenseStatus -eq "6"){
    Write-Output "UPSTREAM: Extended Audit: OS License Status: Extended Grace"}