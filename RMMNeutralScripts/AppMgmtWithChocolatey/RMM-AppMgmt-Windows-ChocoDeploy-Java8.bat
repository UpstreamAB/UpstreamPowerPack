:: Script name: RMM-AppMgmnt-Windows-ChocoDeploy-Java8.bat
:: Script type: Batch.
:: Script description: Deploy latest Java 8 with the Chocolatey application management framework.
:: Dependencies: Chocolatey.
:: Script maintainer: powerpack@upstream.se
:: https://www.upstream.com/powerpack
::
@ECHO UPSTREAM: Script name: RMM-AppMgmnt-Windows-Deploy-Java8.bat
@ECHO UPSTREAM: Deploy Java 8 with Chocolatey.
c:\ProgramData\Chocolatey\choco.exe install jre8 /exclude:64 --limit-output --no-progress -y
@ECHO UPSTREAM: Deploy Java 8 with Chocolatey: End of script: Evaluate the script output.
