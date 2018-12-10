# Script name: RMM-AppMgmnt-Deploy-Windows-Webroot.
# Script type: PowerShell.
# Script description: Deploy Webroot silently with associated Webroot MSP site key.
# Dependencies: Webroot site key to be added as $WebrootKey variable.
# Supported OS: Windows Server 2012, Windows Server 2016, Windows Server 2019, Windows 7, Windows 10.
# Script maintainer: powerpack@upstream.se
# https://www.upstream.com/powerpack"

$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/TenantInfo"

$guids = $subKey.GetSubKeyNames()
foreach($guid in $guids) {
    $guidSubKey = $subKey.OpenSubKey($guid);
    $DisplayName = $guidSubKey.GetValue("DisplayName");
}
#Let's write the Azure Tenant name to the concole for Kaseya to pick up as a variable.
write-output $DisplayName
