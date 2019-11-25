# Script name: KaseyaVSA-Audit-GetPendingRebootStatus.ps1
# Related Kaseya Agent Procedure: "Audit - Windows - Get Pending Reboot Status"
# Script description: Audit if Windows is in apending reboot state from Windows Update.
# Upload this Powershell script to your Kaseya Agent Procedures, Manged Files folder "VSASharedFiles\UpstreamPowerPack\Powershell".
# Supported OS: Windows 8.1, 10, Server 2012, 2016, 2019. PSWindowsUpdate Powersehll module.
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack

If(-not(Get-InstalledModule PSWindowsUpdate -ErrorAction SilentlyContinue))
    {
        Set-PSRepository PSGallery -InstallationPolicy Trusted
        Install-Module PSWindowsUpdate -AllowClobber -Confirm:$False -Force}

Get-WURebootStatus | Select -Expand RebootRequired
