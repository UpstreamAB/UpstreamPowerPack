[cmdletbinding(DefaultParameterSetName='NotReplace')]
param(
    [Parameter(ParameterSetName='Replace', Mandatory=$true)]
    [Parameter(ParameterSetName='ReplaceApiKey', Mandatory=$true)]
    [Switch]$ReplaceApiKey,

    [Parameter(ParameterSetName='Replace', Mandatory=$true)]
    [Parameter(ParameterSetName='ReplaceDataCenter', Mandatory=$true)]
    [Switch]$ReplaceDataCenter,

    [Parameter(ParameterSetName='Replace', Mandatory=$true)]
    [Parameter(ParameterSetName='ReplaceApiKey', Mandatory=$true)]
    [Parameter(ParameterSetName='NotReplace')]
    [String]$ApiKey,

    [Parameter(ParameterSetName='Replace', Mandatory=$true)]
    [Parameter(ParameterSetName='ReplaceDataCenter', Mandatory=$true)]
    [Parameter(ParameterSetName='NotReplace')]
    [ValidateSet( 'US', 'EU')]
    [String]$DataCenter
)


try {
    # Try to import module
    Import-Module -Name 'ITGlueAPI' -ErrorAction Stop
} catch {
    # Failed to import, check if possible to install
    if( (Get-Module -ListAvailable -Name 'ITGlueAPI') ) {
        try {
            Install-Module -Name 'ITGlueAPI'
            Import-Module -Name 'ITGlueAPI'
        } catch {
            Write-Error "Failed to install or import module: $_"
            return;
        }
    } else {
        # The module was not listed for install
        Write-Error 'The module was not available for install.'
        return;
    }
}

try {
    Get-Variable 'ITGlue_API_Key' -ErrorAction Stop
    if($ReplaceApiKey) {
        Add-ITGlueAPIKey -Api_Key $ApiKey
        Export-ITGlueModuleSettings
    }
} catch {
    if($ApiKey) {
        Add-ITGlueAPIKey -Api_Key $ApiKey
        Export-ITGlueModuleSettings
    }
}

try {
    Get-ITGlueBaseURI -ErrorAction Stop
    if($ReplaceDataCenter) {
        Add-ITGlueBaseURI -data_center $DataCenter
        Export-ITGlueModuleSettings
    }
} catch {
    if($DataCenter) {
        Add-ITGlueBaseURI -data_center $DataCenter
        Export-ITGlueModuleSettings
    }
}

try {
    Get-ITGlueContacts -ErrorAction Stop
} catch {
    Write-Error "Unable to connect to the API: $_"
}