#Asset designed by Philip Vedel Düring
$data = @{
    type = 'flexible_asset_types'
    attributes = @{
        name = 'Antivirus'
        description  = ''
        icon = 'search-plus'
        enabled = $true
        show_in_menu = $true
    }
    relationships = @{
        flexible_asset_fields = @{
            data = @(
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 1
                        name = 'Type'
                        kind = 'Select'
                        hint = 'What type of license does this organisation use?'
                        default_value = "Webroot Endpoint Protection`r`n" `
                                      + "Webroot DNS Protection`r`n" `
                                      + "Webroot Security Awareness Training"
                        required = $true
                        show_in_list = $true
                        use_for_title = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 2
                        name = 'GSM Key'
                        kind = 'Text'
                        hint = ''
                        default_value = ''
                        required = $true
                        show_in_list = $true
                        use_for_title = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 3
                        name = 'Log in to GSM Portal'
                        kind = 'Tag'
                        hint = ''
                        tag_type = 'Passwords'
                        required = $true
                        show_in_list = $true
                        use_for_title = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 4
                        name = 'Volume'
                        kind = 'Number'
                        hint = 'How many licenses are in use?'
                        decimals = 0
                        default_value = 0
                        required = $true
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 5
                        name = 'Configurations with Webroot'
                        kind = 'Tag'
                        hint = 'Tag the configurations that Webroot is installed on.'
                        tag_type = 'Configurations'
                        show_in_list = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 6
                        name = 'Expiration date'
                        kind = 'Date'
                        hint = 'Enter the expiration date for the license.'
                        expiration = $true
                        show_in_list = $true
                    }
                }
            )
        }
    }
}
New-ITGlueFlexibleAssetTypes -data $data