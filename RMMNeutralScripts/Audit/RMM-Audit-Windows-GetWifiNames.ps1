<#	
	===========================================================================
		Filename:     	RMM-Audit-Windows-GetWifiNames.ps1
		Latest update:  2019-01-19
		Created by:   	powerpack@upstream.se
		Organization: 	Upstream AB, https://en.upstream.se/powerpack
	===========================================================================
	
	.DESCRIPTION
		Get the history of registered Wifi names saved on local machine for audit and troubleshooting purposes.
  	
	.CHANGELOG
		First release.
#>

$WifiNames = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{ $name = $_.Matches.Groups[1].Value.Trim(); $_ } | %{ (netsh wlan show profile name="$name" key=clear) } | Select-String "Key Content\W+\:(.+)$" | %{ [PSCustomObject]@{ Detected_Wifi_Names = $name } } | Format-Table -AutoSize
Write-Output "UPSTREAM:" $WifiNames
