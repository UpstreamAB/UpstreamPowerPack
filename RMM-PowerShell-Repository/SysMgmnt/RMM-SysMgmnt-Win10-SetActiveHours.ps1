REM ****************
REM Enable Active Hours
REM ****************
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v fActiveHoursEnabled /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v fActiveHoursStart /t REG_DWORD /d 7 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v fActiveHoursEnd /t REG_DWORD /d 19 /f
