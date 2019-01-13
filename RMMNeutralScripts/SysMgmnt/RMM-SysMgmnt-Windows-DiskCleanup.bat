# Script name: RMM-AppMgmt-Windows-DiskCleanup.ps1
# Script type: Powershell
# Script description: Installs 7zip on local machine.
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

#Requires -Version 3

cleanmgr.exe /verylowdisk /d c
