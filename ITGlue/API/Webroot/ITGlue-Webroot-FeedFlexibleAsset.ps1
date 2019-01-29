# Script name: ITGlue-Webroot-FeedFlexibleAsset.ps1
# Script type: Powershell
# Script description: Updates IT Glue with infomation from Webroot
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

#Requires -Version 3

# ----------------------------- UPDATE THE BELOW VARIABLES -----------------------------
# Fill in your Webroot username, password, client ID and client secret. These will be uses for authentication.
$username      = ''
$password      = ''
$client_id     = ''
$client_secret = ''

# Fill in your global GSM key (not site key), this is used to find all the sites.
$global_gsm_key = ''

# Fill in the ID of the flexible asset ID in IT Glue. You create this asset with ITGlue-Webroot-CreateFlexibleAsset.ps1.
$flexible_asset_type_id = 



# ------------------------------- NO NEED THE BELOW CODE -------------------------------
# These functions are used in the script
function Format-WebrootData {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $webroot_data
    )
    process {
        $DNSP = $false
        $WSAT = $false

        foreach($type in $webroot_data.Modules.Type) {
            if($type -eq 'DNSP') { $DNSP = $true }
            if($type -eq 'WSAT') { $WSAT = $true }
        }

        return [PSCustomObject]@{
            SiteKey = $webroot_data.AccountKeyCode
            Volume = $webroot_data.TotalEndpoints
            Expiration = $webroot_data.EndDate
            BillingCycle = $webroot_data.BillingCycle
            BillingDate = $webroot_data.BillingDate
            DNSP = $DNSP
            WSAT = $WSAT
        }
    }
}

function Format-ITGlueData {
    param (
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
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $foramted_webroot_data,

        [Parameter(Mandatory=$true)]
        $formated_itglue_data
    )
    process {
        return @{
            type = 'flexible_assets'
            attributes = @{
                id = $formated_itglue_data.id
                traits = @{
                    # This is data kept from IT Glue.
                    'site-key'                            = $formated_itglue_data.SiteKey
                    'log-in-to-gsm-portal'                = $formated_itglue_data.'log-in-to-gsm-portal'
                    'configurations-with-webroot'         = $formated_itglue_data.'configurations-with-webroot'
                    'webroot-endpoint-protection'         = $formated_itglue_data.'webroot-endpoint-protection'
                    'main-contact-at-customer'            = $formated_itglue_data.'main-contact-at-customer'

                    # This is data updated from Webroot.
                    'volume'                              = $foramted_webroot_data.Volume
                    'expiration-date'                     = $foramted_webroot_data.Expiration
                    'webroot-dns-protection'              = $foramted_webroot_data.DNSP
                    'webroot-security-awareness-training' = $foramted_webroot_data.WSAT
                    'billing-cycle'                       = $foramted_webroot_data.BillingCycle
                    'billing-date'                        = $foramted_webroot_data.BillingDate
                }
            }
        }
    }
}

# Setting the scope (see documentations for details) for the sessions
$scope = 'Console.GSM'

# API_URL is the base URL used for all API calls.
$API_URL = 'https://unityapi.webrootcloudav.com'

# These are the parameters used in the authentication API call.
$api_params = @{
    Headers = @{
        'Authorization' = ('Basic {0}' -f [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($client_id + ':' +$client_secret)))
        'Content-Type' = 'application/x-www-form-urlencoded'
    }
    body = @{
        'username' = $username
        'password' = $password
        'grant_type' = 'password'
        'scope' = $scope
    }
    URI = '{0}/auth/token' -f $API_URL
    Method = 'POST'
}

# Calling the Webroot API for an access token, the access token i used in all future API calls to retreive data.
$access_token = Invoke-RestMethod @api_params | Select-Object -ExpandProperty 'access_token'

# Save access token in a header
$headers = @{'Authorization' = ('Bearer {0}' -f $access_token)}

# Get all data from Webroot and pass it to Format-WebrootData. This will return all data we are interested in.
$sites = Invoke-RestMethod -URI ('{0}/service/api/console/gsm/{1}/sites' -f $API_URL, $global_gsm_key) -Headers $headers | Select-Object -ExpandProperty Sites | Format-WebrootData

# Get all organizations with documented Webroot data from IT Glue and pass it to Format-ITGlueData.
# We get GSM (site) key from here used in the matching.
$organizations = Get-ITGlueFlexibleAssets -filter_flexible_asset_type_id $flexible_asset_type_id | Select-Object -ExpandProperty data | Format-ITGlueData

# An array to hold all new data
$data = @()

# Loop trough all IT Glue organisation
foreach($org in $organizations) {
    # Match GSM keys and pass the releveant organization to Merge-ITGlueWebrootData.
    # Merge-ITGlueWebrootData will replace all data in IT Glue with what we get from Webroot.
    $data += $sites | Where-Object 'SiteKey' -eq $org.SiteKey.Replace('-', '') | Merge-ITGlueWebrootData -formated_itglue_data $org
}

# Upload all data to IT Glue.
Set-ITGlueFlexibleAssets -data $data