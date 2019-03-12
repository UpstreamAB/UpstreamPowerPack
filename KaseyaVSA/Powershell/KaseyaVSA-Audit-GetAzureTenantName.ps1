# Script name: KaseyaVSA-Audit-GetAzureTenantName.ps1
# Related Kaseya Agent Procedure: "Audit - Windows 10 - Custom Field - Azure AD Info"
# Script description: Audit the Azure tenant name on a Windows 10 computer if present.
# Upload this Powershell script to your Kaseya Agent Procedures folder "VSASharedFiles\UpstreamPowerPack\Powershell".
# Supported OS: Windows 10
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/TenantInfo"

$guids = $subKey.GetSubKeyNames()
foreach($guid in $guids) {
    $guidSubKey = $subKey.OpenSubKey($guid);
    $DisplayName = $guidSubKey.GetValue("DisplayName");
}
# Let's write the Azure Tenant name to the concole for Kaseya VSA to pick up as a variable.
write-output $DisplayName
