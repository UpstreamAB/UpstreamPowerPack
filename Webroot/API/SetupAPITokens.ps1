# Webroot credentials
$username =""
$password = ""
$cliend_id = ""
$client_secret = ""
$AccountID = ""
$scope = "Console.GSM"

# Schedule settings
# Scheduler task path
$scheduler_task_path = "\Webroot\"
# Schedule task name
$refresh_scheduler_taskname = "NewRefreshToken"
$access_scheduler_taskname = "NewAccessToken"
# Script Name
$refresh_token_script = "NewRefreshToken.ps1"
$access_token_script = "NewAccessToken.ps1"
# Script path ($PSScriptRoot = execution path)
$script_path = $PSScriptRoot

# Config and token folders
$config_path = "$($env:USERPROFILE)\UpstreamPowerpack"
$token_path = "$($env:USERPROFILE)\UpstreamPowerpack"

# Config and token files
$config_file = "webrootconfig.psd1"
$tokens_file = "webroottoken.psd1"

# API URL and paths
$API_URL = "https://unityapi.webrootcloudav.com"
$API_refresh_path = "/auth/token"

# Removing trailing backslash
if($config_path.EndsWith("\")) {
    $config_path = $config_path.Remove($config_path.Length -1, 1)
}
if($token_path.EndsWith("\")) {
    $token_path = $token_path.Remove($token_path.Length -1, 1)
}
if($script_path.EndsWith("\")) {
    $script_path = $script_path.Remove($script_path.Length -1, 1)
}

# Create directory if not existing
if(-not (test-path $config_path)) {
    New-Item -ItemType Directory -Force -Path $config_path  | %{$_.Attributes = "hidden"}
}
if(-not (test-path $token_path)) {
    New-Item -ItemType Directory -Force -Path $token_path  | %{$_.Attributes = "hidden"}
}

# Export settings
@"
@{
    username = "$username"
    password = "$($password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)"
    cliend_id = "$cliend_id"
    client_secret = "$($client_secret | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)"
    token_path = "$token_path\$tokens_file"
    accountid = "$($AccountID | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)"
}
"@ | Out-File -FilePath "$config_path\$config_file" -Force

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

# API call & API Parameters
$resp = Invoke-RestMethod @params

# Export token
@"
@{
    access_token = @{
        token = "$($resp.access_token | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)"
        expire = "$(((Get-Date).AddSeconds($resp.expires_in)).Ticks)"
        token_type = "$($resp.token_type)"
    }
    refresh_token = @{
        token = "$($resp.refresh_token | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)"
        expire = "$(((Get-Date).AddDays(14)).Ticks)"
    }
    scope = "$($resp.scope.Trim("[").Trim("]").Trim("`""))"
}
"@ | Out-File -FilePath "$token_path\$tokens_file" -Force

# Schedule renewal of refresh token
# Action
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -command `"& `'$script_path\$refresh_token_script`'`""
# Trigger
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddDays(13)
# Settings
$settings = New-ScheduledTaskSettingsSet -WakeToRun -RestartCount 3 -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -StartWhenAvailable -RestartInterval (New-TimeSpan -Minutes 3)
try {
    # Check if task exists, catch if not
    Get-ScheduledTask -TaskName $refresh_scheduler_taskname -TaskPath $scheduler_task_path -ErrorAction Stop
    # Update trigger if it does
    Set-ScheduledTask -TaskPath $scheduler_task_path -TaskName $refresh_scheduler_taskname -Trigger $trigger
} catch {
    # Create if it does not exist and add to task scheduler
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskPath $scheduler_task_path -TaskName $refresh_scheduler_taskname -Settings $settings -Force
}

# Schedule renewal of access token
# Action
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -command `"& `'$script_path\$access_token_script`'`""
# Trigger
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Addseconds($resp.expires_in - 30)
# Settings
$settings = New-ScheduledTaskSettingsSet -WakeToRun -RestartCount 3 -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -StartWhenAvailable -RestartInterval (New-TimeSpan -Minutes 3)
try {
    # Check if task exists, catch if not
    Get-ScheduledTask -TaskName $access_scheduler_taskname -TaskPath $scheduler_task_path -ErrorAction Stop
    # Update trigger if it does
    Set-ScheduledTask -TaskPath $scheduler_task_path -TaskName $access_scheduler_taskname -Trigger $trigger
} catch {
    # Create if it does not exist and add to task scheduler
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskPath $scheduler_task_path -TaskName $access_scheduler_taskname -Settings $settings -Force
}