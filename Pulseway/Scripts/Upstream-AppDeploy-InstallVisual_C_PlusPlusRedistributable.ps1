<#
=================================================================================
Pulseway script    Upstream: AppDeploy: Install Visual C++ Redistributable
Support type       Upstream Pulseway Power Pack
Support            Upstream AB, powerpack@upstream.se
Lastest version    2021-12-20
=================================================================================

.DESCRIPTION
This Powershell script will install Install Visual C++ Redistributable on a Windows Server or computer with no reboot. Reboot may however be needed.
#>

# -----------------------------------------------------------------------------------------------------------------------
# VARIABLES & OPTIONS

# Downloading the executable from here: "https://docs.microsoft.com/en-US/cpp/windows/latest-supported-vc-redist?view=msvc-170".
$Url = "https://aka.ms/vs/17/release/vc_redist.x64.exe"

# Let's agree on the folder and EXE file name. You probably don't need to change this.
$Folder = "C:\PulsewayTemp"
$File = "$Folder\vc_redist.x64.exe"

# The method for downloading the file.
$WebClient = New-Object System.Net.WebClient

# END OF VARIABLES & OPTIONS
# -----------------------------------------------------------------------------------------------------------------------


# Checking for download Folder. Create if missing.
If (-not (Test-Path -LiteralPath $Folder)) {
    Write-Output "UPSTREAM: AppDeploy: Preparations: $Folder Does Not Exists. Creating." 
    New-Item -Path "$Folder" -ItemType Directory >$Null }

Else {
    Write-Output "UPSTREAM: AppDeploy: Preparations: $Folder Exists." }


# Downloading the file.
Write-Output "UPSTREAM: AppDeploy: Preparations: Downloading the installer file from $Url."
$WebClient.DownloadFile($Url, $File)


# Execute the file.
Write-Output "UPSTREAM: AppDeploy: Installing the application $File."
Start-Process $File /qn


Write-Output "UPSTREAM: AppDeploy: Done. Finishing up with some house cleaning."
# Execute the file Pulseway temp folder.
Remove-Item -Path $Folder -Recurse


Write-Output "Powered by Upstream Power Pack Premium (support@upstream.se), www.upstreampowerpack.com"
