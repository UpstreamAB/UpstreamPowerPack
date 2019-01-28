$data = @{
    type = "flexible_asset_types"
    attributes = @{
        icon = "crosshairs"
        description = "Webroot specific infromation"
        name = "Webroot"
        enabled = $true
    }
    relationships = @{
        flexible_asset_fields = @{
            data = @(
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 1
                        name = "Site Key"
                        kind = "Text"
                        hint = "Enter your GSM site here. This will be the"
                        required = $true
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        name_key = "site-key"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 2
                        name = "Log in to GSM Portal"
                        kind = "Tag"
                        tag_type = "Passwords"
                        required = $true
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        name_key = "log-in-to-gsm-portal"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 3
                        name = "Volume"
                        kind = "Number"
                        hint = "How many licenses are in use?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        name_key = "volume"
                        default_value = "0"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 4
                        name = "Configurations with Webroot"
                        kind = "Tag"
                        hint = "Tag the configurations that Webroot is installed on."
                        tag_type = "Configurations"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        name_key = "configurations-with-webroot"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 5
                        name = "Expiration date"
                        kind = "Date"
                        hint = "When does the licenses expire?"
                        required = $false
                        use_for_title = $false
                        expiration = $true
                        show_in_list = $true
                        name_key = "expiration-date"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 6
                        name = "Webroot Endpoint Protection"
                        kind = "Checkbox"
                        hint = "Is Webroot Endpoint Protection licensed?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        name_key = "webroot-endpoint-protection"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 7
                        name = "Webroot DNS Protection"
                        kind = "Checkbox"
                        hint = "Is Webroot DNS Protection licensed?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        name_key = "webroot-dns-protection"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 8
                        name = "Webroot Security Awareness Training"
                        kind = "Checkbox"
                        hint = "Is Webroot Security Awareness Training licensed?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        name_key = "webroot-security-awareness-training"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 9
                        name = "Main contact at customer"
                        kind = "Tag"
                        hint = "Who is our main contact (if any) at the customer for any Webroot questions?"
                        tag_type = "Contacts"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        name_key = "main-contact-at-customer"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 12
                        name = "Billing Cycle"
                        kind = "Text"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        name_key = "billing-cycle"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 13
                        name = "Billing Date"
                        kind = "Text"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        name_key = "billing-date"
                        default_value = ""
                    }
                }
            )
        }
    }
}

New-ITGlueFlexibleAssetTypes -data $data