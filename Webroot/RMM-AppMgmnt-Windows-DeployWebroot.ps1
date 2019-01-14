# Script name: RMM-AppMgmnt-Windows-DeployWebroot.ps1
# Script type: PowerShell.
# Script description: Deploy Webroot silently with associated Webroot MSP site key using any RMM tool.
# Dependencies: Webroot site key to be added as $WebrootKey variable.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack"

#Setting up the variables needed.
$Url = "http://anywhere.webrootcloudav.com/zerol/wsasme.msi"
$File = "c:\temp\wsasme.msi"
$WebrootKey = "XXXX-XXXX-XXXX-XXXX"
$WebClient = New-Object System.Net.WebClient

#Download the software installation package.
Write-Output "UPSTREAM: Deploy Webroot: Downloading Webroot MSI installer from" $Url "and waiting for completion."
$WebClient.DownloadFile($Url,$File)

#Deploy the software.
Write-Output "UPSTREAM: Deploy Webroot: Silent installation begins. Waiting for succesful event log response."
msiexec /i $File GUILIC=$WebrootKey CMDLINE="SME,quiet" /qn

#Validate successful installation by looking at the Windows Application event log. 
$StartInstallDate = (Get-Date)
$SucessfullInstall = $Null
do
{
    $SucessfullInstall = get-eventlog -logname application -Source "MSIInstaller" | where {$_.eventID -eq 11707} | Where-Object {$_.Message -like '*Webroot SecureAnywhere -- Installation operation completed successfully*'}   
}
until ($SucessfullInstall)

#Get proper success messages back to the host console.
Write-Output "UPSTREAM: Deploy Webroot: Webroot installed silently with site key" $WebrootKey"."
