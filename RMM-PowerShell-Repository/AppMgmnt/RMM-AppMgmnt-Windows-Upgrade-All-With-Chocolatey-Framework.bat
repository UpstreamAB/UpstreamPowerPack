REM Script name: RMM-AppMgmnt-Windows-Upgrade-All-With-Chocolatey-Framework.bat
REM Script type: Batch.
REM Script description: Upgrade all supported applications with the Chocolatey application management framework.
REM Dependencies: Powershell.
REM Supported OS: Windows Server 2012, Windows Server 2016, Windows Server 2019, Windows 7, Windows 10.
REM Script maintainer: powerpack@upstream.se
REM https://www.upstream.com/powerpack"
REM
@ECHO UPSTREAM: Upgrade All With Chocolatey: Upgrading all supported apps.
c:\ProgramData\Chocolatey\choco.exe upgrade all --limit-output --no-progress -y
@ECHO UPSTREAM: Upgrade All With Chocolatey: End of script: Evaluate the script output."     
