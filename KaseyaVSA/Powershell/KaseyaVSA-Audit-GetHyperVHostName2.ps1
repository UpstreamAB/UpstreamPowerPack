# Script name: KaseyaVSA-Audit-GetHyperVHostName.ps1
# Related Kaseya Agent Procedure: "Audit - Windows 10 - Custom Field - Azure AD Info"
# Script description: Audit the Azure tenant user name on a Windows 10 computer
# Dependencies: Existing registry values
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack"

$HyperVHostName = (Get-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters').PhysicalHostName

Write-Output $HyperVHostName

