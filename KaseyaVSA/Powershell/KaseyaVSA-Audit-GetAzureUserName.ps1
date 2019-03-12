# Script name: KaseyaVSA-Audit-GetAzureUserName.ps1
# Related Kaseya Agent Procedure: "Audit - Windows 10 - Custom Field - Azure AD Info"
# Script description: Audit the Azure tenant user name on a Windows 10 computer.
# Upload this Powershell script to your Kaseya Agent Procedures folder "VSASharedFiles\UpstreamPowerPack\Powershell".
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
# Let's write the Azure Tenant User Name to the concole for Kaseya VSA to pick up as a variable.
write-output $UserEmail
