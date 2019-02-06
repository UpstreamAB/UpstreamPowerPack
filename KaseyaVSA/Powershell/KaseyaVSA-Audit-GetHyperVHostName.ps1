# Script name: KaseyaVSA-Audit-GetHyperVHostName.ps1
# Related Kaseya Agent Procedure: 
# Script description: 
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

$HyperVHostName = Get-VMhost | Select-Object Name
write-output $HyperVHostName
