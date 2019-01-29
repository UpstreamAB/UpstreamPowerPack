$data = @{
    type = 'flexible_asset_types'
    attributes = @{
        name = 'Major Incidents'
        description  = 'For logging of major incidents.'
        icon = 'clock-o'
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
                        name = 'Incident'
                        kind = 'Text'
                        hint = 'And the incident name as title.'
                        show_in_list = $true
                        use_for_title = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 2
                        name = 'Ticket number'
                        kind = 'Text'
                        default_value = 'Configurations'
                        hint = ''
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 3
                        name = 'Date'
                        kind = 'Date'
                        hint = 'When did the incident occur?'
                        required = $true
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 4
                        name = 'Affected Assets'
                        kind = 'Tag'
                        tag_type = 'Configurations'
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 5
                        name = 'Severity'
                        kind = 'Select'
                        hint = 'Affected users?'
                        default_value = "One User`r`n" `
                                      + "Multiple Users`r`n" `
                                      + "Whole Company"
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 6
                        name = 'Which users?'
                        kind = 'Tag'
                        hint = 'Tag all the affected users'
                        tag_type = 'Contacts'
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 7
                        name = 'Details'
                        kind = 'Textbox'
                        hint = 'Describe the incident.'
                        show_in_list = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 8
                        name = 'Solution'
                        kind = 'Textbox'
                        hint = 'What is done to solve the incident'
                        show_in_list = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 9
                        name = 'Responsible'
                        kind = 'Tag'
                        hint = 'Who is responsible?'
                        tag_type = "Contacts"
                        show_in_list = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 10
                        name = 'Incident reported as GDPR breach'
                        kind = 'Checkbox'
                        hint = 'Does this incident require to be reported as a GDPR breach?'
                        show_in_list = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 11
                        name = 'GDPR breach report date'
                        kind = 'Date'
                        hint = 'If true above, when did we report this incet as a GDPR breach?'
                        show_in_list = $true
                        expiration = $false
                    }
                }
            )
        }
    }
}
New-ITGlueFlexibleAssetTypes -data $data
