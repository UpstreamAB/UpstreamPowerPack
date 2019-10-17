# Script name: ITGlue-Webroot-FeedFlexibleAsset.ps1
# Script type: Powershell
# Script description: Updates IT Glue Felxible Aset "Webroot" with infomation from Webroot.
# Dependencies: Powershell 3.0, ITGluePowerShell Wrapper
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

#Requires -Version 3
#Requires -Modules @{ ModuleName='ITGlueAPI'; ModuleVersion='2.0.7' }

# ----------------------------- UPDATE THE BELOW VARIABLES -----------------------------
# Fill in your Webroot username, password, client ID and client secret. These will be uses for authentication.
param(
    $username      = '',
    $password      = '',
    $client_id     = '',
    $client_secret = '',
    # Fill in your global GSM key (not site key), this is used to find all the sites.
    $global_gsm_key = '',
    # Fill in the ID of the flexible asset ID in IT Glue. You create this asset with ITGlue-Webroot-CreateFlexibleAsset.ps1.
    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='The id of the asset in IT Glue')]
    [long]$flexible_asset_type_id = '',

    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='IT Glue api key')]
    $api_key = (Get-ITGlueAPIKey | ConvertFrom-SecureString),

    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='Where is your data stored? EU or US?')]
    [ValidateSet('US', 'EU')]
    $data_center = 'EU'
)



# ------------------------------- NO NEED EDIT THE BELOW CODE ----------------------------
$username =       [PSCredential]::new('null', ($username       | ConvertTo-SecureString)).GetNetworkCredential().Password
$password =       [PSCredential]::new('null', ($password       | ConvertTo-SecureString)).GetNetworkCredential().Password
$client_id =      [PSCredential]::new('null', ($client_id      | ConvertTo-SecureString)).GetNetworkCredential().Password
$client_secret =  [PSCredential]::new('null', ($client_secret  | ConvertTo-SecureString)).GetNetworkCredential().Password
$global_gsm_key = [PSCredential]::new('null', ($global_gsm_key | ConvertTo-SecureString)).GetNetworkCredential().Password
$api_key =        [PSCredential]::new('null', ($api_key        | ConvertTo-SecureString)).GetNetworkCredential().Password

# If any parameter is missing
# Cannot use mandatory because it would break setting parameters inside the script.
if(!$flexible_asset_type_id -or !$api_key -or !$data_center) {
    return "One or more parameter(s) is missing. This script will not continue."
}

# Set API key for this sessions
Add-ITGlueAPIKey -api_key $api_key
# Set data center for this sessions
Add-ITGlueBaseURI -data_center $data_center

# These functions are used in the script
function Format-WebrootData {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $webroot_data
    )
    process {
        $DNSP = $false # DNS Protection
        $SAT = $false # Security Awareness Training
        $WEP = !$webroot_data.Deactivated # Webrood Endpoint protection. True if site is deactivated, i.e. false = active and true = inactive, thus invert it.

        # Look for DNS Protection and Secruity Awareness Traning licenses
        foreach($type in $webroot_data.Modules.Type) {
            if($type -eq 'DNSP') { $DNSP = $true }
            if($type -eq 'SAT') { $SAT = $true }
        }


        # Cannot get active endpoints if site is inactive
        if($WEP) {
            $endpoints_active = @()
            $endpoints_inactive = @()

            $pageNr = 1
            # Get all endpoints with Webroot installed
            $endpoints = Invoke-RestMethod -URI ('https://unityapi.webrootcloudav.com/service/api/console/gsm/{0}/sites/{1}/endpoints?pageSize=50&pageNr={2}' -f $global_gsm_key, $webroot_data.siteid, $pageNr) -Headers $headers
            # Keep asking until there are not more endpoints
            while($endpoints.TotalAvailable -ne 0) {
                # All active (billed) endpoints
                $endpoints_active += $endpoints.Endpoints | Where Deactivated -eq $false
                # All inactive (not billed) endpoints
                $endpoints_inactive += $endpoints.Endpoints | Where Deactivated -eq $true
                # Get next set of data (if any)
                $endpoints = Invoke-RestMethod -URI ('https://unityapi.webrootcloudav.com/service/api/console/gsm/{0}/sites/{1}/endpoints?pageSize=50&pageNr={2}' -f $global_gsm_key, $webroot_data.siteid, ++$pageNr) -Headers $headers
            }
        }

        return [PSCustomObject]@{
            Keycode              = $webroot_data.AccountKeyCode
            Volume               = $webroot_data.TotalEndpoints
            Expiration           = $webroot_data.EndDate
            BillingCycle         = $webroot_data.BillingCycle
            BillingDate          = $webroot_data.BillingDate
            DNSP                 = $DNSP
            SAT                  = $SAT
            WEP                  = $WEP
            endpoints_active     = $endpoints_active
            endpoints_inactive   = $endpoints_inactive
        }
    }
}

function Format-ITGlueData {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $itglue_data
    )
    process {
        # Get all configurations from current organisation, used for syncing active and inactive endpoints.
        $itglue_configrations = Get-ITGlueConfigurations -organization_id $itglue_data.attributes.'organization-id' -page_size 1000 | Select-Object -ExpandProperty data

        # If more than 1000s configurations
        $page_number = 1
        while($itglue_configrations.links.next) {
            $itglue_configrations += Get-ITGlueConfigurations -organization_id $itglue_data.attributes.'organization-id' -page_size 1000 -page_number ++$page_number | Select-Object -ExpandProperty data
        }

        return [PSCustomObject]@{
            flexible_asset_id                     = $itglue_data.id
            Keycode                               = $itglue_data.attributes.traits.'site-key'
            'log-in-to-gsm-portal'                = $itglue_data.attributes.traits.'log-in-to-gsm-portal'.values.id
            'configurations-with-webroot'         = $itglue_data.attributes.traits.'configurations-with-webroot'.values.id
            'webroot-endpoint-protection'         = $itglue_data.attributes.traits.'webroot-endpoint-protection'
            'webroot-dns-protection'              = $itglue_data.attributes.traits.'webroot-dns-protection'
            'webroot-security-awareness-training' = $itglue_data.attributes.traits.'webroot-security-awareness-training'
            'main-contact-at-customer'            = $itglue_data.attributes.traits.'main-contact-at-customer'.values.id
            configurations                        = $itglue_configrations
            oldData = @{
                'volume-active-licenses'               = $itglue_data.attributes.traits.'volume-active-licenses'
                'expiration-date'                      = $itglue_data.attributes.traits.'expiration-date'
                'webroot-endpoint-protection'          = $itglue_data.attributes.traits.'webroot-endpoint-protection'
                'webroot-dns-protection'               = $itglue_data.attributes.traits.'webroot-dns-protection'
                'webroot-security-awareness-training'  = $itglue_data.attributes.traits.'webroot-security-awareness-training'
                'billing-cycle'                        = $itglue_data.attributes.traits.'billing-cycle'
                'billing-date'                         = $itglue_data.attributes.traits.'billing-date'
                'active-configurations-with-webroot'   = $itglue_data.attributes.traits.'active-configurations-with-webroot'.values.id
                'inactive-configurations-with-webroot' = $itglue_data.attributes.traits.'inactive-configurations-with-webroot'.values.id
            }
        }
    }
}

function Merge-ITGlueWebrootData {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $formated_webroot_data,

        [Parameter(Mandatory=$true)]
        $formated_itglue_data
    )
    process {
        # Cannot get active endpoints if site is inactive in Webroot, thus cannot match.
        if($formated_webroot_data.WEP){
            $formated_active_endpoints = @()
            $formated_inactive_endpoints = @()

            foreach($config in $formated_itglue_data.configurations) {
                if($config.attributes.'mac-address') {
                    # If endpoint is listed as active
                    if($formated_webroot_data.endpoints_active.MACAddress -contains $config.attributes.'mac-address'.Replace('-',':')) {
                        $formated_active_endpoints += $config.id
                    # If endpoint is listed as inactive
                    } elseif($formated_webroot_data.endpoints_inactive.MACAddress -contains $config.attributes.'mac-address'.Replace('-',':')) {
                        $formated_inactive_endpoints += $config.id
                    }
                }
            }
        }

        $update = $false

        if([int]$formated_itglue_data.oldData.'volume-active-licenses' -ne $formated_webroot_data.Volume) {
            $update = $true
        } elseif($formated_itglue_data.oldData.'expiration-date' -ne $formated_webroot_data.Expiration.Substring(0,10)) {
            $update = $true
        } elseif($formated_itglue_data.oldData.'webroot-endpoint-protection' -ne $formated_webroot_data.WEP) {
            $update = $true
        } elseif($formated_itglue_data.oldData.'webroot-dns-protection' -ne $formated_webroot_data.DNSP) {
            $update = $true
        } elseif($formated_itglue_data.oldData.'webroot-security-awareness-training' -ne $formated_webroot_data.SAT) {
            $update = $true
        } elseif($formated_itglue_data.oldData.'billing-cycle' -ne $formated_webroot_data.BillingCycle) {
            $update = $true
        } elseif($formated_itglue_data.oldData.'billing-date' -ne $formated_webroot_data.BillingDate) {
            $update = $true
        } elseif($formated_active_endpoints | ? {$formated_itglue_data.oldData.'active-configurations-with-webroot' -notcontains $_}) {
            $update = $true
        } elseif($formated_inactive_endpoints | ? {$formated_itglue_data.oldData.'inactive-configurations-with-webroot' -notcontains $_}) {
            $update = $true
        } elseif($formated_itglue_data.oldData.'active-configurations-with-webroot' | ? {$formated_active_endpoints -notcontains $_}) {
            $update = $true
        } elseif($formated_itglue_data.oldData.'inactive-configurations-with-webroot' | ? {$formated_inactive_endpoints -notcontains $_}) {
            $update = $true
        }


        if($update) {
            return @{
                type = 'flexible_assets'
                attributes = @{
                    id = $formated_itglue_data.flexible_asset_id
                    traits = @{
                        # This is data kept from IT Glue.
                        'site-key'                             = $formated_itglue_data.Keycode
                        'log-in-to-gsm-portal'                 = $formated_itglue_data.'log-in-to-gsm-portal'
                        'main-contact-at-customer'             = $formated_itglue_data.'main-contact-at-customer'

                        # This is data updated from Webroot.
                        'volume-active-licenses'               = $formated_webroot_data.Volume
                        'active-configurations-with-webroot'   = $formated_active_endpoints
                        'inactive-configurations-with-webroot' = $formated_inactive_endpoints
                        'expiration-date'                      = $formated_webroot_data.Expiration
                        'webroot-endpoint-protection'          = $formated_webroot_data.WEP
                        'webroot-dns-protection'               = $formated_webroot_data.DNSP
                        'webroot-security-awareness-training'  = $formated_webroot_data.SAT
                        'billing-cycle'                        = $formated_webroot_data.BillingCycle
                        'billing-date'                         = $formated_webroot_data.BillingDate

                        # Update time logging
                        'last-update'                          = $(Get-date -UFormat '%Y-%m-%d %T')

                        # Keeping relase info
                        'flexible-asset-release-information'  = 'v1.0 2019-10-31'
                    }
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
    $data += $sites | Where-Object 'Keycode' -eq $org.Keycode.Replace('-', '') | Merge-ITGlueWebrootData -formated_itglue_data $org
}

# Upload all data to IT Glue.
if($data) {
    Set-ITGlueFlexibleAssets -data $data
}