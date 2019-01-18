# Webroot credentials
$username =""
$password = ""
$cliend_id = ""
$client_secret = ""
$AccountID = ""

# Config and token folders
$config_path = "$($env:USERPROFILE)\UpstreamPowerpack"

# Config and token files
$config_file = "webrootconfig.psd1"

# Removing trailing backslash
if($config_path.EndsWith("\")) {
    $config_path = $config_path.Remove($config_path.Length -1, 1)
}

# Create directory if not existing
if(-not (test-path $config_path)) {
    New-Item -ItemType Directory -Force -Path $config_path  | %{$_.Attributes = "hidden"}
}

# Export settings
@"
@{
    username = "$username"
    password = "$($password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)"
    cliend_id = "$cliend_id"
    client_secret = "$($client_secret | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)"
    accountid = "$($AccountID | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)"
}
"@ | Out-File -FilePath "$config_path\$config_file" -Force