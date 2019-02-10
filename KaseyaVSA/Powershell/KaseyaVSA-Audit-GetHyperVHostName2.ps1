# Script name: KaseyaVSA-Audit-GetAzureUserName.ps1
# Related Kaseya Agent Procedure: "Audit - Windows 10 - Custom Field - Azure AD Info"
# Script description: Audit the Azure tenant user name on a Windows 10 computer
# Dependencies: Existing registry values
# Supported OS: Windows 10.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack"

$HyperVHostName = (get-item "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters").GetValue("PhysicalHostName")
# Let's write the Azure Tenant User Name to the concole for Kaseya VSA to pick up as a variable.
Write-Output $HyperVHostName
