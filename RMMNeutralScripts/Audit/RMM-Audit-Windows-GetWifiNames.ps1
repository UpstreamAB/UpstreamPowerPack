$WifiNames = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{ $name = $_.Matches.Groups[1].Value.Trim(); $_ } | %{ (netsh wlan show profile name="$name" key=clear) } | Select-String "Key Content\W+\:(.+)$" | %{ [PSCustomObject]@{ Detected_Wifi_Names = $name } } | Format-Table -AutoSize
Write-Output "UPSTREAM:" $WifiNames
