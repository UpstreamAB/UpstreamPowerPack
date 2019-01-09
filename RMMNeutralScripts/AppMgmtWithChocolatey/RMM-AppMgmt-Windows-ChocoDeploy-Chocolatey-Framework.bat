:: Script name: RMM-AppMgmnt-Windows-ChocoDeploy-Chocolatey-Framework.bat
:: Script type: Batch.
:: Script description: Deploy Chocolatey framewok for application management.
:: Dependencies: Powershell 1.0.
:: Supported OS: Windows Server 2012, Windows Server 2016, Windows Server 2019, Windows 7, Windows 10.
:: Script maintainer: powerpack@upstream.se
:: https://www.upstream.com/powerpack"
::
@ECHO UPSTREAM: Deploy Chocolatey: Deploying Chocolatey Framework from www.chocolatey.org
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
@ECHO UPSTREAM: Deploy Chocolatey: End of script: Evaluate script output.
