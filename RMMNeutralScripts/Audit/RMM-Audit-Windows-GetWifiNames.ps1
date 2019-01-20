<#	
	===========================================================================
		Filename:     	RMM-Audit-Windows-GetWifiNames.ps1
		Latest update:  2019-01-19
		Created by:   	powerpack@upstream.se
		Organization: 	Upstream AB, https://en.upstream.se/powerpack
	===========================================================================
	.DESCRIPTION
		Uses the System.Net.WebClient function fo grab the Google Chrome MSI package from URL and install
		silently with msiexec command. Reports back success or failure based on Add/Remove Programs list
	
  .NOTES
		First release.
#>

$WifiNames = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{[PSCustomObject]@{ Detected_Wifi_Names=$name }} | Format-Table -AutoSize 
Write-Output "UPSTREAM: $WifiNames
