# Config and token folders
$config_path = "$($env:USERPROFILE)\UpstreamPowerpack"
$token_path = "$($env:USERPROFILE)\UpstreamPowerpack"

# Config and token files
$config_file = "webrootconfig.psd1"
$tokens_file = "webroottoken.psd1"

# Removing trailing backslash
if($config_path.EndsWith("\")) {
    $config_path = $config_path.Remove($config_path.Length -1, 1)
}
if($token_path.EndsWith("\")) {
    $token_path = $token_path.Remove($token_path.Length -1, 1)
}

# Import config data
$config = Import-PowerShellDataFile -Path "$config_path\$config_file"
$tokens = Import-PowerShellDataFile -Path "$token_path\$tokens_file"

# Extract data from import
$access_token = [System.Management.Automation.PSCredential]::New('null', $($tokens.access_token.token | ConvertTo-SecureString)).GetNetworkCredential().Password
$accountid = [System.Management.Automation.PSCredential]::New('null', $($config.AccountID | ConvertTo-SecureString)).GetNetworkCredential().Password

# API URL and paths
$API_URL = "https://unityapi.webrootcloudav.com"
$API_path = "/service/api/console/gsm/$accountid/sites"


# See if token has expired
if([DateTime][int64]$tokens.access_token.expire -lt $(Get-Date)) {
    Write-Error "Access token has expired"
    return
}

$headers = @{
    "Authorization" = "Bearer $access_token"
    "content-type" = "application/x-www-form-urlencoded"
    "Accept" = "application/json"
}

$resp = Invoke-RestMethod -Method 'GET' -URI ($API_URL + $API_path) -Headers $headers
$resp.Sites | Select-Object SiteId, SiteName, TotalEndpoints