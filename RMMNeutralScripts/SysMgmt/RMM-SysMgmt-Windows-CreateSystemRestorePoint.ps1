# Script name: RMM-SysMgmt-Windows-CreateSystemRestorePoint.ps1
# Script type: Powershell
# Script description: Creates system restore point
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------
Checkpoint-Computer -Description UpstreamPowerPackRecoveryPoint
