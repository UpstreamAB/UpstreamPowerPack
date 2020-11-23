<#
=================================================================================
Pulseway script:    Audit: Win10: Default Browser
Support type:       Upstream Pulseway Power Free
Support:            Upstream AB, powerpack@upstream.se
Lastest version:    2020-10-28

Required variable inputs:
None

Required variable outputs:
Name: "OutputDefaultBrowser"
Default Value: "Not Detected"
Associated Custom Field: "OS: Browser: Default"
=================================================================================
#>

# As we are running this script as Local System we need get the current user name, SID and registry hive. 
$CurrentUser = Get-Process -Name Explorer -IncludeUserName | Select -Expand Username
$SID = (New-Object -ComObject Microsoft.DiskQuota).TranslateLogonNameToSID((Get-WmiObject -Class Win32_ComputerSystem).Username)
New-PSDrive AllUsersRegistry Registry HKEY_USERS >$Null

If ($CurrentUser -ne $Null){
        $CurrentBrowser = (Get-ItemProperty "AllUsersRegistry:\$SID\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name Progid | Select-Object -Expand Progid)
        
    If ($CurrentBrowser -Match "Firefox"){
        $OutputDefautlBrowser = "Firefox"}

    If ($CurrentBrowser -Match "Chrome"){
        $OutputDefautlBrowser = "Google Chrome"}

    If ($CurrentBrowser -Match "MSEdge"){
        $OutputDefautlBrowser = "Chromium Edge"}

    If ($CurrentBrowser -Match "AppX"){
        $OutputDefautlBrowser = "Legacy Edge"}

    If ($CurrentBrowser -Match "IE.HTTP"){
        $OutputDefautlBrowser = "Internet Explorer"}

    Write-Output "UPSTREAM: Extended Audit: Standard Browser: Registry Name: $CurrentBrowser"
    Write-Output "UPSTREAM: Extended Audit: Standard Browser: Friendly Name: $OutputDefautlBrowser"
}

Else{
    Write-Output "UPSTREAM: Extended Audit: Standard Browser: No user logged in"}

Start-Process -FilePath "$env:PWY_HOME\CLI.exe" -ArgumentList ("setVariable OutputDefautlBrowser ""$OutputDefautlBrowser""") -Wait
