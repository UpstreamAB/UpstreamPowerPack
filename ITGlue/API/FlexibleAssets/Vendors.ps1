$data = @{
    type = 'flexible_asset_types'
    attributes = @{
        name = 'Vendors'
        description = 'Vendor Information'
        icon = 'caret-square-o-right'
        show_in_menu = $true
        enabled = $true
    }
    relationships = @{
        flexible_asset_fields = @{
            data = @(
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 1
                        name = 'Vendor Name'
                        kind = 'Text'
                        hint = 'Used for title (e.g. Search results, Tags, Related Items)'
                        default_value = ''
                        required = $true
                        show_in_list = $true
                        use_for_title = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 2
                        name = 'Vendor Organization'
                        kind = 'Tag'
                        hint = 'Tag vendor organization'
                        tag_type = 'Organizations'
                        required = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 3
                        name = 'Account Number'
                        kind = 'Text'
                        hint = ''
                        default_value = ''
                        required = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 4
                        name = 'Support Phone Line'
                        kind = 'Tag'
                        hint = 'Tag support phone line(s) - may need to be created as a contact(s)'
                        tag_type = 'Contacts'
                        required = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 5
                        name = 'Support Website URL'
                        kind = 'Text'
                        hint = 'e.g. https://www.itglue.com/support'
                        default_value = ''
                        required = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 6
                        name = 'Account Manager'
                        kind = 'Tag'
                        hint = 'Fill in account manager name, email, telephone'
                        tag_type = 'Contacts'
                        required = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 7
                        name = 'SLA'
                        kind = 'Select'
                        hint = 'Select response/resolution time commitment'
                        default_value = "4-Hour`r`n" `
                                      + "24-Hour`r`n" `
                                      + "Best Effort`r`n" `
                                      + "None"
                        required = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 8
                        name = 'Notes'
                        kind = 'Textbox'
                        hint = ''
                        default_value = ''
                        required = $false
                        show_in_list = $false
                    }
                }
            )
        }
    }
}
New-ITGlueFlexibleAssetTypes -data $data
