RMM-Audit-Win10-GetAzureTenantName.ps1

$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/TenantInfo"

$guids = $subKey.GetSubKeyNames()
foreach($guid in $guids) {
    $guidSubKey = $subKey.OpenSubKey($guid);
    $AzureTenantName = $guidSubKey.GetValue("DisplayName");
}
write-output $AzureTenantName
