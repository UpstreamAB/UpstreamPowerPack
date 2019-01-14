# Extract data from import
$access_token = ""
$accountid = ""

# API URL and paths
$API_URL = "https://unityapi.webrootcloudav.com"
$API_path = "/service/api/console/gsm/$accountid/sites"

$headers = @{
    "Authorization" = "Bearer $access_token"
    "content-type" = "application/x-www-form-urlencoded"
    "Accept" = "application/json"
}

$resp = Invoke-RestMethod -Method 'GET' -URI ($API_URL + $API_path) -Headers $headers
$resp.Sites | Select-Object SiteId, SiteName, TotalEndpoints