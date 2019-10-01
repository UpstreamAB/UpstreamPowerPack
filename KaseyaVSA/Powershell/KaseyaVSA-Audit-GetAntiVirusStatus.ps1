# Script name: KaseyaVSA-Audit-GetAntiVirusStatus.ps1
# Related Kaseya Agent Procedure: "Audit - Windows 10 - Custom Field - Get AV Status"
# Script description: Queries the local machine if any AV other than Defender is installed.
# Upload this Powershell script to your Kaseya Agent Procedures folder "VSASharedFiles\UpstreamPowerPack\Powershell".
# Supported OS: Windows 10
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

function Get-AntivirusName { 
[cmdletBinding()]     
param ( 
[string]$ComputerName = "$env:computername" , 
$Credential 
) 
    $wmiQuery = "SELECT * FROM AntiVirusProduct" 
    $AntivirusProduct = Get-WmiObject -Namespace "root\SecurityCenter2" -Query $wmiQuery  @psboundparameters         
    [array]$AntivirusNames = $AntivirusProduct.displayName       
    Switch($AntivirusNames) {
        {$AntivirusNames.Count -eq 0}{"AV NOT DETCTED";Continue}
        {$AntivirusNames.Count -eq 1 -and $_ -eq "Windows Defender"} {Write-host "ONLY Windows Defender is installed!";Continue}
        {$_ -ne "Windows Defender"} {"AV DETECTED"}
   }
}
Get-AntivirusNam
