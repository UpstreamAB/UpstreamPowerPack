# Webroot credentials
$username =""
$password = ""
$cliend_id = ""
$client_secret = ""
$scope = "*"

# API URL and paths
$API_URL = "https://unityapi.webrootcloudav.com"
$API_refresh_path = "/auth/token"

$params = @{
    Headers = @{
        "Authorization" = "Basic $([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($cliend_id + ":" +$client_secret)))"
        "Content-Type" = "application/x-www-form-urlencoded"
    }
    body = @{
        "username" = $username
        "password" = $password
        "grant_type" = 'password'
        "scope" = $scope
    }
    URI = $API_URL + $API_refresh_path
    Method = "POST"
}

# API call
return Invoke-RestMethod @params