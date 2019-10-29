# Google Chrome Update Service
$ServiceName = 'gupdate'
$ServiceIndex = ((Get-ItemProperty 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor\Services\').PSobject.Properties | Where {$_.Value -eq $ServiceName}).Name
Write-Output $ServiceName
Write-Output $ServiceIndex
Remove-ItemProperty -Path 'HKLM:\Software\MMSOFT Design\PC Monitor\Services' -Name "$ServiceIndex"

# Software Protection Servie
$ServiceName = 'sppsvc'
$ServiceIndex = ((Get-ItemProperty 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor\Services\').PSobject.Properties | Where {$_.Value -eq $ServiceName}).Name
Write-Output $ServiceName
Write-Output $ServiceIndex
Remove-ItemProperty -Path 'HKLM:\Software\MMSOFT Design\PC Monitor\Services' -Name "$ServiceIndex"

# Remote Registry Service
$ServiceName = 'RemoteRegistry'
$ServiceIndex = ((Get-ItemProperty 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor\Services\').PSobject.Properties | Where {$_.Value -eq $ServiceName}).Name
Write-Output $ServiceName
Write-Output $ServiceIndex
Remove-ItemProperty -Path 'HKLM:\Software\MMSOFT Design\PC Monitor\Services' -Name "$ServiceIndex"

# Remove Windows Modules Installer Service
$ServiceName = 'TrustedInstaller'
$ServiceIndex = ((Get-ItemProperty 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor\Services\').PSobject.Properties | Where {$_.Value -eq $ServiceName}).Name
Write-Output $ServiceName
Write-Output $ServiceIndex
Remove-ItemProperty -Path 'HKLM:\Software\MMSOFT Design\PC Monitor\Services' -Name "$ServiceIndex"

# Remove Background Intelligent Transfer Service
$ServiceName = 'BITS'
$ServiceIndex = ((Get-ItemProperty 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor\Services\').PSobject.Properties | Where {$_.Value -eq $ServiceName}).Name
Write-Output $ServiceName
Write-Output $ServiceIndex
Remove-ItemProperty -Path 'HKLM:\Software\MMSOFT Design\PC Monitor\Services' -Name "$ServiceIndex"

# Remove Windows Update Services
$ServiceName = 'wuauserv'
$ServiceIndex = ((Get-ItemProperty 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor\Services\').PSobject.Properties | Where {$_.Value -eq $ServiceName}).Name
Write-Output $ServiceName
Write-Output $ServiceIndex
Remove-ItemProperty -Path 'HKLM:\Software\MMSOFT Design\PC Monitor\Services' -Name "$ServiceIndex"

# Remove Windows Biometric Service
$ServiceName = 'WbioSrvc'
$ServiceIndex = ((Get-ItemProperty 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor\Services\').PSobject.Properties | Where {$_.Value -eq $ServiceName}).Name
Write-Output $ServiceName
Write-Output $ServiceIndex
Remove-ItemProperty -Path 'HKLM:\Software\MMSOFT Design\PC Monitor\Services' -Name "$ServiceIndex"

# Remove Shell Hardware Detection
$ServiceName = 'ShellHWDetection'
$ServiceIndex = ((Get-ItemProperty 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor\Services\').PSobject.Properties | Where {$_.Value -eq $ServiceName}).Name
Write-Output $ServiceName
Write-Output $ServiceIndex
Remove-ItemProperty -Path 'HKLM:\Software\MMSOFT Design\PC Monitor\Services' -Name "$ServiceIndex"
