<#
=================================================================================
Filename:           RMM-Audit-Win10-GetAzureTenantName.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-07-06
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
