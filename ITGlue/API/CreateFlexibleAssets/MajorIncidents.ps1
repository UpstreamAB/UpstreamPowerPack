$data = @{
    type = "flexible_asset_types"
    attributes = @{
        icon = "clock-o"
        description = "For logging of major incidents."
        name = "Major Incidents"
        enabled = $true
    }
    relationships = @{
        flexible_asset_fields = @{
            data = @(
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 1
                        name = "Incident"
                        kind = "Text"
                        hint = "And the incident name as title."
                        required = $false
                        use_for_title = $true
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 2
                        name = "Ticket number"
                        kind = "Text"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        default_value = "Configurations"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 3
                        name = "Date"
                        kind = "Date"
                        hint = "When did the incident occur?"
                        required = $true
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 4
                        name = "Affected Assets"
                        kind = "Tag"
                        tag_type = "Configurations"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 5
                        name = "Severity"
                        kind = "Select"
                        hint = "Affected users?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        default_value = "One User\r\nMultiple Users\r\nWhole Company"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 6
                        name = "Which users?"
                        kind = "Tag"
                        hint = "Tag all the affected users"
                        tag_type = "Contacts"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 7
                        name = "Details"
                        kind = "Textbox"
                        hint = "Describe the incident."
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 8
                        name = "Solution"
                        kind = "Textbox"
                        hint = "What is done to solve the incident"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 9
                        name = "Responsible"
                        kind = "Tag"
                        hint = "Who is responsible?"
                        tag_type = "Contacts"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                  }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 10
                        name = "Incident reported as GDPR breach"
                        kind = "Checkbox"
                        hint = "Does this incident require to be reported as a GDPR breach?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 11
                        name = "GDPR breach report date"
                        kind = "Date"
                        hint = "If $true above when did we report this incet as a GDPR breach?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 12
                        name = "This documentation is powered by Upstream Power Pack"
                        kind = "Header"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        default_value = ""
                    }
                }
            )
        }
    }
}
New-ITGlueFlexibleAssetTypes -data $data
