$data = @{
    type = "flexible_asset_types"
    attributes = @{
        icon = "cogs"
        description = "This flexible asset will help specifying on prem applications."
        name = "On-Prem Apps"
        enabled = $true
    }
    relationships = @{
        flexible_asset_fields = @{
            data = @(
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 1
                        name = "Application name"
                        kind = "Select"
                        hint = "Select from the list the application you want to document. Any application missing may be added under account flexible asset types."
                        required = $true
                        use_for_title = $true
                        expiration = $false
                        show_in_list = $true
                        default_value = "Hogia Beslutsstöd\nHogia Lön\nLundalogik Lime\nMicrosoft Office\nMicrosoft Office 365\nSolidWorks\nSuperOffice CRM\nUnitrends Backup\nVeeam Backup\nVisma Administration\nVisma Anläggningsregister\nVisma Lön\nVisma Tid\nVMware vSphere\nVMware Workstation\nNot on the list (ask admin to add)"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 2
                        name = "Vendor"
                        kind = "Tag"
                        hint = "Tag the vendor"
                        tag_type = "Organizations"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 3
                        name = "Application version"
                        kind = "Text"
                        hint = "Try to add the version of the application by name like =2010 2016 6.7 LT v3412.85 Advanced etc."
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
                        order = 4
                        name = "Managed by us?"
                        kind = "Select"
                        hint = "Is this application our responsability and managed by us?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = "Yes\r\nNo"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 5
                        name = "License information"
                        kind = "Header"
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
                        name = "License key"
                        kind = "Text"
                        hint = "Enter the current license key for this application."
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = ""
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 7
                        name = "License expires"
                        kind = "Date"
                        hint = "Enter the expiration date for the license."
                        required = $false
                        use_for_title = $false
                        expiration = $true
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 8
                        name = "License volume"
                        kind = "Number"
                        hint = "How many licenses?"
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
                        order = 9
                        name = "Contains Personal Data"
                        kind = "Select"
                        hint = "Do this application fall under GDPR restrictions and regulations?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = "Yes\r\nNo"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 10
                        name = "Important contacts"
                        kind = "Header"
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
                        name = "Application admin(s) at the customer"
                        kind = "Tag"
                        hint = "Do the customer have specific application administrator(s) for this application?"
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
                        order = 12
                        name = "Financial application owner at the customer"
                        kind = "Tag"
                        hint = "Who pays the bills? Can be the same as the application administrator."
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
                        order = 13
                        name = "Our specialist(s)"
                        kind = "Tag"
                        hint = "Who is our application spcialist(s)?"
                        tag_type = "AccountsUsers"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 14
                        name = "Application setup"
                        kind = "Header"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 15
                        name = "How is this application delivered?"
                        kind = "Select"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = "Centralized from one or more servers\r\nLocally from a computer"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 16
                        name = "Associated servers(s) or computer(s)"
                        kind = "Tag"
                        hint = "Tag the server(s) or computers(s) running this application"
                        tag_type = "Configurations"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 17
                        name = "Application User Interface"
                        kind = "Select"
                        hint = "Is this a web browser based application or does it require a software installation?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = "Browser based only\r\nLocal software only\r\nMobile App only\r\nBrowser and Mobile App\r\nBrowser and local software\r\nBrowser local software and mobile App"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 18
                        name = "Application URL (if available)"
                        kind = "Text"
                        hint = "Is this application accessible via any internal or external web page?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = ""
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 19
                        name = "Is there any SSL certificate(s) used by this application"
                        kind = "Tag"
                        hint = "Is there any existing SSL certificate(s) tied to this application?"
                        tag_type = "SslCertificates"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                       show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 20
                        name = "Client installation name"
                        kind = "Text"
                        hint = "Does this application require any client installation for computers? If so what is the name of this client?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = ""
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 21
                        name = "RMM Deploy script"
                        kind = "Text"
                        hint = "Do this application have any RMM deploy script(s) for easy deployment? State the script name(s)."
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = ""
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 22
                        name = "Password and security"
                        kind = "Header"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 23
                        name = "Password(s)"
                        kind = "Tag"
                        hint = "Tag the password(s) associated with this app for administration purposes."
                        tag_type = "Passwords"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 24
                        name = "Security groups or privileges required?"
                        kind = "Textbox"
                        hint = "Is there any requirements on local or domain admin group(s) in order to run this application? State the group names."
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = ""
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 25
                        name = "Licensed Users"
                        kind = "Tag"
                        hint = "Is there any licensed named user(s) tied to this application?"
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
                        order = 26
                        name = "Upgraded to SQL?"
                        kind = "Select"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        default_value = "Yes\r\nNo"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    attributes = @{
                        order = 27
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
