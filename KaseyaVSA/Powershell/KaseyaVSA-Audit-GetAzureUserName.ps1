# Script name: KaseyaVSA-Audit-GetAzureUserName.ps1
# Related Kaseya Agent Procedure: "Audit - Windows 10 - Custom Field - Azure AD Info"
# Script description: Audit the Azure tenant user name on a Windows 10 computer
# Dependencies: Existing registry values
# Supported OS: Windows 10.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack"

$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo"

$guids = $subKey.GetSubKeyNames()
foreach($guid in $guids) {
    $guidSubKey = $subKey.OpenSubKey($guid);
    $UserEmail = $guidSubKey.GetValue("UserEmail");
}
write-output $UserEmail
