# Script name: KaseyaVSA-Audit-GetAzureUserName.ps1
# Script type: PowerShell.
# Script description: Audit the Azure tenant user name on a Windows 10 computer.
# Dependencies: Azure AD joined.
# Supported OS: Windows 10.
# Script maintainer: powerpack@upstream.se
# https://www.upstream.com/powerpack"

$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo"

$guids = $subKey.GetSubKeyNames()
foreach($guid in $guids) {
    $guidSubKey = $subKey.OpenSubKey($guid);
    $UserEmail = $guidSubKey.GetValue("UserEmail");
}
write-output $UserEmail
