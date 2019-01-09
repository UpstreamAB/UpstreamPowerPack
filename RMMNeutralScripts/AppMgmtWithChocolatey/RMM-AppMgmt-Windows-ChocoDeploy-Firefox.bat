:: Script name: RMM-AppMgmnt-Windows-Deploy-Firefox.bat
:: Script type: Batch.
:: Script description: Deploy Firefox wit the help of Chocolatey framewok for application management.
:: Dependencies: Powershell 1.0.
:: Supported OS: Windows Server 2012, Windows Server 2016, Windows Server 2019, Windows 7, Windows 10.
:: Script maintainer: powerpack@upstream.se
:: https://www.upstream.com/powerpack"
::
@ECHO UPSTREAM: Deploy Firefox: Deploying Firefox with Chocolatey Framework from www.chocolatey.org
c:\ProgramData\Chocolatey\choco.exe install firefox --limit-output --no-progress -y
@ECHO UPSTREAM: Deploy Firefox: End of script: Evaluate script output."
