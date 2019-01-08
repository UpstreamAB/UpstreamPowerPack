:: Script name: RMM-AppMgmnt-Windows-Deploy-Java8.bat
:: Script type: Batch.
:: Script description: Deploy latest Java 8 with the Chocolatey application management framework.
:: Dependencies: Powershell.
:: Supported OS: Windows Server 2012, Windows Server 2016, Windows Server 2019, Windows 7, Windows 10.
:: Script maintainer: powerpack@upstream.se
:: https://www.upstream.com/powerpack
::
@ECHO UPSTREAM: Script name: RMM-AppMgmnt-Windows-Deploy-Java8.bat
@ECHO UPSTREAM: Deploy Java 8 with Chocolatey.
c:\ProgramData\Chocolatey\choco.exe install jre8 --limit-output --no-progress -y
@ECHO UPSTREAM: Deploy Java 8 with Chocolatey: End of script: Evaluate the script output.
