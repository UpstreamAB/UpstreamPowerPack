<#
=================================================================================
Filename:           RMM-Audit-Win10-Audit-GetDefautlWebBrowserForCurrentUser.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-07-06
=================================================================================
#>

$SID = (New-Object -ComObject Microsoft.DiskQuota).TranslateLogonNameToSID((Get-WmiObject -Class Win32_ComputerSystem).Username)
New-PSDrive AllUsersRegistry Registry HKEY_USERS >$Null

$CurrentBrowser = (Get-ItemProperty "AllUsersRegistry:\$SID\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name Progid | Select-Object -Expand Progid)

If (!$CurrentBrowser) { Write-Output "UPSTREAM: No current user" }

If ($CurrentBrowser -Match "Firefox") { $CurrentBrowserFriendlyName = "Firefox" }

If ($CurrentBrowser -Match "Chrome") { $CurrentBrowserFriendlyName = "Google Chrome" }

If ($CurrentBrowser -Match "MSEdge") { $CurrentBrowserFriendlyName = "Chromium Edge" }

If ($CurrentBrowser -Match "AppX") { $CurrentBrowserFriendlyName = "Legacy Edge" }

If ($CurrentBrowser -Match "IE.HTTP") { $CurrentBrowserFriendlyName = "Internet Explorer" }

# Remove the AllUsersRegistry PSDrive from memory.
Remove-PSDrive AllUsersRegistry -Force

Write-Output "UPSTREAM: $CurrentBrowserFriendlyName"
