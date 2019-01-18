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
                        order = 1$data = @{
    type = 'flexible_asset_types'
    attributes = @{
        icon = 'crosshairs'
        description = 'Webroot specific infromation'
        name = 'Webroot clone'
        show_in_menu = $true
        enabled = $true
    }
    relationships = @{
        flexible_asset_fields = @{
            data =  @(
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 1
                        name = 'Site Key'
                        kind = 'Text'
                        hint = 'Enter your GSM site here. This will be the'
                        required = $true
                        show_in_list = $true
                        use_for_title = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 2
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
                        order = 3
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
                        order = 4
                        name = 'Configurations with Webroot'
                        kind = 'Tag'
                        hint = 'Tag the configurations that Webroot is installed on.'
                        tag_type = 'Configurations'
                        required = $true
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 5
                        name = 'Expiration date'
                        kind = 'Date'
                        hint = 'When does the licenses expire?'
                        required = $true
                        expiration = $true
                        show_in_list = $true
                        use_for_title = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 6
                        name = 'Webroot Endpoint Protection'
                        kind = 'Checkbox'
                        hint = 'Is Webroot Endpoint Protection licensed?'
                        required = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 7
                        name = 'Webroot DNS Protection'
                        kind = 'Checkbox'
                        hint = 'Is Webroot DNS Protection licensed?'
                        required = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 8
                        name = 'Webroot Security Awareness Training'
                        kind = 'Checkbox'
                        hint = 'Is Webroot Security Awareness Training licensed?'
                        required = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 9
                        name = 'Main contact at customer'
                        kind = 'Tag'
                        hint = 'Who is our main contact (if any) at the customer for any Webroot questions?'
                        tag_type = 'AccountsUsers'
                        required = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 10
                        name = 'Main expert(s) at Upstream'
                        kind = 'Text'
                        hint = 'Who is our main Webroot experts?'
                        required = $false
                        show_in_list = $true
                        use_for_title = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 11
                        name = 'Webroot License Information'
                        kind = 'Checkbox'
                        hint = 'Check this box to enable this felxible asset for a Organisation'
                        required = $false
                        show_in_list = $true
                    }
                }
            )
        }
    }
}

New-ITGlueFlexibleAssetTypes -data $data
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