<#
=================================================================================
Filename:           UPSTREAM-KaseyaVSA-Audit-WorkplaceEssentials-GetAzureTenantName.ps1
Kaseya Procedure:   Custom Field - Audit - Windows 10 - Get Azure AD Tenant And User
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2021-12-22
=================================================================================
#>

Try{
    $subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/TenantInfo" -ErrorAction Stop
    $guids = $subKey.GetSubKeyNames()
    foreach($guid in $guids) {
        $guidSubKey = $subKey.OpenSubKey($guid)
        $AzureTenantName = $guidSubKey.GetValue("DisplayName")}
        Write-Output $AzureTenantName}

Catch{
    Write-Output "Not Detected"}
