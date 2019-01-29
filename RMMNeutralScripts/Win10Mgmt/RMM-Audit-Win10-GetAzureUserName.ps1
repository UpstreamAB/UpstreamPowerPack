# Script name: RMM-Audit-Win10-GetAzureUserName.ps1
# Script type: PowerShell
# Script description: Audits the Windows 10 machine for Azure AD user name.
# Dependencies: Windows 10
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo"
$guids = $subKey.GetSubKeyNames()
foreach($guid in $guids) {
    $guidSubKey = $subKey.OpenSubKey($guid);
    $AzureUserName = $guidSubKey.GetValue("UserEmail");
}
write-output $AzureUserName
