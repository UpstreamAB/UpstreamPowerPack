# Script name: ITGlue-Webroot-CreateFlexibleAsset.ps1
# Script type: Powershell
# Script description: Creates a custom Felxible Asset called "Webroot". Use "ITGlue-Webroot-CreateFlexibleAsset.ps1" to update. 
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

$data = @{
    type = "flexible_asset_types"
    attributes = @{
        icon = "crosshairs"
        description = "Webroot specific infromation"
        name = "Webroot clone"
        enabled = $true
    }
    relationships = @{
        flexible_asset_fields = @{
            data = @(
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 1
                        name = "Keycode"
                        kind = "Text"
                        hint = "Enter the keycode for the corresponding customer"
                        required = $true
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
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
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 3
                        name = "Volume (active licenses)"
                        kind = "Number"
                        hint = "How many licenses are in use?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        default_value = "0"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 4
                        name = "Active configurations with Webroot"
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
                        name = "Inactive configurations with Webroot"
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
                        order = 6
                        name = "Expiration date"
                        kind = "Date"
                        hint = "When does the licenses expire?"
                        required = $false
                        use_for_title = $false
                        expiration = $true
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 7
                        name = "Webroot Endpoint Protection"
                        kind = "Checkbox"
                        hint = "Is Webroot Endpoint Protection licensed?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 8
                        name = "Webroot DNS Protection"
                        kind = "Checkbox"
                        hint = "Is Webroot DNS Protection licensed?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 9
                        name = "Webroot Security Awareness Training"
                        kind = "Checkbox"
                        hint = "Is Webroot Security Awareness Training licensed?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 10
                        name = "Main contact at customer"
                        kind = "Tag"
                        hint = "Who is our main contact (if any) at the customer for any Webroot questions?"
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
                        order = 11
                        name = "Billing Cycle"
                        kind = "Text"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 12
                        name = "Billing Date"
                        kind = "Text"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 13
                        name = "Last update"
                        kind = "Text"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        default_value = ""
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 14
                        name = "This automated documentation is powered by Upstream Power Pack"
                        kind = "Header"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                }
            )
        }
    }
}
New-ITGlueFlexibleAssetTypes -data $data
