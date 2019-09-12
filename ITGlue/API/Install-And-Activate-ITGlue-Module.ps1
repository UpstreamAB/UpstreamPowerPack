[cmdletbinding(DefaultParameterSetName='NotReplace')]
param(
    [Parameter(ParameterSetName = 'Replace', Mandatory=$true)]
    [Parameter(ParameterSetName='NotReplace')]
    [String]$ApiKey,

    [ValidateSet( 'US', 'EU')]
    [Parameter(ParameterSetName='Replace')]
    [Parameter(ParameterSetName='NotReplace')]
    [String]$DataCenter,

    [Parameter(ParameterSetName='Replace')]
    [Switch]$ReplaceApiKey
)

# Check if module is installed
try {
    Import-Module ITGlueAPI -ErrorAction Stop
} catch {
    if(-not (Get-Module -ListAvailable ITGlueAPI)) {
        Install-Module -Name ITGlueAPI
    }
}

# Replace API key if asked
if($ReplaceApiKey) {
    Add-ITGlueAPIKey -Api_Key $apikey
    Export-ITGlueModuleSettings
}

try {
    Get-Variable ITGlue_API_Key -ErrorAction Stop > $null
    Get-Variable ITGlue_Base_URI -ErrorAction Stop > $null
} catch {
    if($apikey) {
        Add-ITGlueAPIKey -Api_Key $apikey
    }
    if($datacenter) {
        Add-ITGlueBaseURI -data_center $datacenter
    }
    Export-ITGlueModuleSettings
}

try {
    [void](Get-ITGlueContacts -ErrorAction Stop)
} catch{
    Write-Error 'Your API key is not valid.'
}