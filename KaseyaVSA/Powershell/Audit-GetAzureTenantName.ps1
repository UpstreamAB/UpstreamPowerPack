$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/TenantInfo"

$guids = $subKey.GetSubKeyNames()
foreach($guid in $guids) {
    $guidSubKey = $subKey.OpenSubKey($guid);
    $DisplayName = $guidSubKey.GetValue("DisplayName");
}
#Let's write the Azure Tenant name to the concole for Kaseya to pick up as a variable.
write-output $DisplayName
