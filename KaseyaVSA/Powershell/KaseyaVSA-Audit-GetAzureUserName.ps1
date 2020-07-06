<#
=================================================================================
Filename:           UPSTREAM-KaseyaVSA-Audit-Win10-GetAzureUserName.ps1
Kaseya Procedure:   Custom Field - Audit - Windows 10 - Get Azure AD Tenant And User
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-04-22
=================================================================================
#>

Try{
    $subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo" -ErrorAction Stop
    $guids = $subKey.GetSubKeyNames()
    foreach($guid in $guids) {
        $guidSubKey = $subKey.OpenSubKey($guid)
        $AzureUserName = $guidSubKey.GetValue("UserEmail")}
        Write-Output $AzureUserName}

Catch{
    Write-Output "Not Detected"}
