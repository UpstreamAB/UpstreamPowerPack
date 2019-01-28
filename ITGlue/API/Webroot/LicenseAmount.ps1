# Webroot credentials
$username =""
$password = ""
$cliend_id = ""
$client_secret = ""
$global_gsm_key = ""

# Flexible asset ID in IT Glue
$flexible_asset_type_id = 

# Functions used in the script
function Format-WebrootData {
    param (
        [Object]
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $webroot_data
    )
    process {
        return [PSCustomObject]@{
            SiteKey = $webroot_data.AccountKeyCode
            Volume = $webroot_data.TotalEndpoints
            Expiration = $webroot_data.EndDate
            BillingCycle = $webroot_data.BillingCycle
            BillingDate = $webroot_data.BillingDate
        }
    }
}

function Format-ITGlueData {
    param (
        [Object]
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $itglue_data
    )
    process {
        return [PSCustomObject]@{
            id = $itglue_data.id
            SiteKey = $itglue_data.attributes.traits.'site-key'
            'log-in-to-gsm-portal'                = $itglue_data.attributes.traits.'log-in-to-gsm-portal'.values.id
            'configurations-with-webroot'         = $itglue_data.attributes.traits.'configurations-with-webroot'.values.id
            'webroot-endpoint-protection'         = $itglue_data.attributes.traits.'webroot-endpoint-protection'
            'webroot-dns-protection'              = $itglue_data.attributes.traits.'webroot-dns-protection'
            'webroot-security-awareness-training' = $itglue_data.attributes.traits.'webroot-security-awareness-training'
            'main-contact-at-customer'            = $itglue_data.attributes.traits.'main-contact-at-customer'.values.id
        }
    }
}

function Merge-ITGlueWebrootData {
    param (
        [Object]
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $foramted_webroot_data,

        [Object]
        [Parameter(Mandatory=$true)]
        $formated_itglue_data
    )
    process {
        return @{
            type = 'flexible_assets'
            attributes = @{
                id = $formated_itglue_data.id
                traits = @{
                    'site-key'                            = $formated_itglue_data.SiteKey
                    'log-in-to-gsm-portal'                = $formated_itglue_data.'log-in-to-gsm-portal'
                    'volume'                              = $foramted_webroot_data.Volume
                    'configurations-with-webroot'         = $formated_itglue_data.'configurations-with-webroot'
                    'expiration-date'                     = $foramted_webroot_data.Expiration
                    'webroot-endpoint-protection'         = $formated_itglue_data.'webroot-endpoint-protection'
                    'webroot-dns-protection'              = $formated_itglue_data.'webroot-dns-protection'
                    'webroot-security-awareness-training' = $formated_itglue_data.'webroot-security-awareness-training'
                    'main-contact-at-customer'            = $formated_itglue_data.'main-contact-at-customer'
                    'billing-cycle'                       = $foramted_webroot_data.BillingCycle
                    'billing-date'                        = $foramted_webroot_data.BillingDate
                }
            }
        }
    }
}

# Don't touch, it's Von Dutch
$scope = "Console.GSM"

# API URL and paths
$API_URL = "https://unityapi.webrootcloudav.com"
$API_refresh_path = "/auth/token"

$api_params = @{
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
$access_token = Invoke-RestMethod @api_params | Select-Object -ExpandProperty "access_token"

# Save access token in new headers
$headers = @{'Authorization' = "Bearer $access_token"}

# Webroot data
$sites = Invoke-RestMethod -URI "$API_URL/service/api/console/gsm/$global_gsm_key/sites" -Headers $headers | Select-Object -ExpandProperty Sites | Format-WebrootData

# IT Glue data
$organizations = Get-ITGlueFlexibleAssets -filter_flexible_asset_type_id $flexible_asset_type_id | Select-Object -ExpandProperty data | Format-ITGlueData

$data = @()
foreach($org in $organizations) {
    # Use only data from the relevent organization
    $data += $sites | Where-Object 'SiteKey' -eq $org.SiteKey.Replace('-', '') | Merge-ITGlueWebrootData -formated_itglue_data $org
}

Set-ITGlueFlexibleAssets -data $data