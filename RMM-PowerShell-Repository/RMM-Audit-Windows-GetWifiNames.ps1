#This one-liner will get the list of Wifi names from a Windows machine.
(netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{[PSCustomObject]@{ Detected_Wifi_Names=$name }} | Format-Table -AutoSize 
