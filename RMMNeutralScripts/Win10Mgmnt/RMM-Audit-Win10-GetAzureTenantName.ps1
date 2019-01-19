# Script name: RMM-Audit-Win10-GetAzureTenantName.ps1
# Script type: PowerShell
# Script description: Audits the Windows 10 machine for Azure AD tenant name.
# Dependencies: Windows 10
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/TenantInfo"
$guids = $subKey.GetSubKeyNames()
foreach($guid in $guids) {
    $guidSubKey = $subKey.OpenSubKey($guid);
    $AzureTenantName = $guidSubKey.GetValue("DisplayName");
}
write-output $AzureTenantName
