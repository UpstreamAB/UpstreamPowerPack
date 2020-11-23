<#
=================================================================================
Pulseway script:    Policy: Win10: Disable Fast Boot
Support type:       Upstream Pulseway Power Free
Support:            Upstream AB, powerpack@upstream.se
Lastest version:    2020-10-28
=================================================================================
#>

Set-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value "0"
