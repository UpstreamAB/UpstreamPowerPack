# Script name: RMM-Audit-Win10-GetAzureTenantName.ps1
# Script type: Powershell
# Script description: Uninstalls Google Chrome on local machine.
# Dependencies: Powershell 3.0, Windows 10
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/TenantInfo"
$guids = $subKey.GetSubKeyNames()
foreach($guid in $guids) {
    $guidSubKey = $subKey.OpenSubKey($guid);
    $AzureTenantName = $guidSubKey.GetValue("DisplayName");
}
write-output $AzureTenantName
