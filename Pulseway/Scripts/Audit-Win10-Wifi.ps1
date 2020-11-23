<#
=================================================================================
Pulseway script:    Audit: Win10: Wifi
Support type:       Upstream Pulseway Power Free
Support:            Upstream AB, powerpack@upstream.se
Lastest version:    2020-10-28

Required variable inputs:
None

Name: "OutputWifiSSID"
Default Value: "Not Audited"
Associated Custom Field: "Network: Wifi: Last Used SSID"

Required variable outputs:
Name: OutputWifiSignalStrength
Default Value: "Not Audited"
Associated Custom Field: "Network: Wifi: Last Signal Strength"
=================================================================================
#>

$OutputWifiSignalStrength = (netsh wlan show interfaces) -Match '^\s+Signal' -Replace '^\s+Signal\s+:\s+',''
$OutputWifiSSID = (netsh wlan show interfaces) -Match '^\s+SSID' -Replace '^\s+SSID\s+:\s+',''

Write-Output "UPSTREAM: Extended Audit: Wifi: Signal Strength: $OutputWifiSignalStrength"
Write-Output "UPSTREAM: Extended Audit: Wifi: SSID: $OutputWifiSSID"

Start-Process -FilePath "$env:PWY_HOME\CLI.exe" -ArgumentList ("setVariable OutputWifiSignalStrength ""$OutputWifiSignalStrength""") -Wait
Start-Process -FilePath "$env:PWY_HOME\CLI.exe" -ArgumentList ("setVariable OutputWifiSSID ""$OutputWifiSSID""") -Wait
