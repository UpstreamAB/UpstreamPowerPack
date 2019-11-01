$data = @{
    type = "flexible_asset_types"
    Attributes = @{
        icon = "cloud"
        description = "This flexible asset is designed specifically for Cloud applications. This is part of Upstream\u0027s IT Glue customer on-boarding procedure."
        Name = "Cloud Apps"
        enabled = $true
    }
    relationships = @{
        flexible_asset_fields = @{
            data = @(
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 1
                        Name = "Application name"
                        kind = "Select"
                        hint = "The name of the application like Office 365 Business Premium Salesforce Drobpbox etc."
                        required = $false
                        use_for_title = $true
                        expiration = $false
                        show_in_list = $true
                        default_value = "Kaseya VSA\r\nKaseya BMS\r\nKaseya Authanvil\r\nIT Glue\r\nAudit Guru for GDPR\r\nAuvik\r\nWebroot\r\nMySelfServicePortal.com\r\n--------------------------------\r\nOffice 365 Business\r\nOffice 365 Business Premium\r\nOffice 365 Business Essentials\r\nDropbox\r\nSalesforce\r\nFortnox\r\nHogia\r\nVisma Administration\r\nVisma Lön\r\nVisma Tid\r\nHogia Smart Ekonomi\r\nNavision\r\nMailchimp\r\nZoom Meeting"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 2
                        Name = "Licensed Users"
                        kind = "Tag"
                        hint = "Tag the specific contacts using this application"
                        tag_type = "Contacts"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 3
                        Name = "License key"
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
                    Attributes = @{
                        order = 4
                        Name = "Application URL"
                        kind = "Text"
                        hint = "What is the URL for this application?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = ""
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 5
                        Name = "Application user interface"
                        kind = "Select"
                        hint = "Is this a web browser based application or does it require a software installation?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = "Browser based only\r\nLocal software only\r\nMobile App only\r\nBrowser and Mobile App\r\nBrowser and local software\r\nBrowser local software and mobile App\r\n"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 6
                        Name = "Subscription period (contract period)"
                        kind = "Select"
                        hint = "What is the agreed subscription (contract) period for this application?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = "Monthly\r\nYearly\r\n2 years\r\n3 years\r\nOther\r\n"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 7
                        Name = "Subscription expires"
                        kind = "Date"
                        hint = "When do the Cloud software subscription agreement expire?"
                        required = $false
                        use_for_title = $false
                        expiration = $true
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 8
                        Name = "Important contacts"
                        kind = "Header"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 9
                        Name = "Financial application owner at the customer"
                        kind = "Tag"
                        hint = "Who pays the bills? Can be the same as the application administrator."
                        tag_type = "Contacts"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 10
                        Name = "Application admin(s) at the customer"
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
                    Attributes = @{
                        order = 11
                        Name = "Our application specialist(s)"
                        kind = "Tag"
                        hint = "Here you can tag our application specialist(s) for this application?"
                        tag_type = "AccountsUsers"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 12
                        Name = "Passwords and security"
                        kind = "Header"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 13
                        Name = "Passwords"
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
                    Attributes = @{
                        order = 14
                        Name = "RMM Deployment Agent Procedure"
                        kind = "Text"
                        hint = "Can this application be deployed with a Agent Procedure? What is the name?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = "Type the name of the Kaseya Agent Procedure here."
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 15
                        Name = "Requires 2factor authentication"
                        kind = "Select"
                        hint = "Does this application requires any 2factor verification."
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                        default_value = "Yes\r\nNo"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 16
                        Name = "2factor solution used"
                        kind = "Select"
                        hint = "If yes on requires 2factor authentication what solution do the customer use?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        default_value = "Authanvil\r\nOneLogin\r\nOcta\r\nDUO\r\nGoogle Authenticator\r\nMacosoft Authenticator\r\nOther (take note)"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 17
                        Name = "GDPR Related Information"
                        kind = "Header"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 18
                        Name = "Contains Personal Data"
                        kind = "Select"
                        hint = "Do this application fall under GDPR restrictions and regulations?"
                        required = $true
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        default_value = "Yes\r\nNo"
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 19
                        Name = "Vendor"
                        kind = "Tag"
                        hint = "Tag vendor"
                        tag_type = "FlexibleAssetType =882106698318053"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 20
                        Name = "Notes"
                        kind = "Text"
                        hint = "Any addition notes?"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $false
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 21
                        Name = "This documentation is powered by Upstream Power Pack"
                        kind = "Header"
                        required = $false
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        default_value = ""
                    }
                },
                @{
                    type = "flexible_asset_fields"
                    Attributes = @{
                        order = 22
                        Name = "New additional info"
                        kind = "Select"
                        hint = "Måste uppdateras inom datum bla bla bla"
                        required = $true
                        use_for_title = $false
                        expiration = $false
                        show_in_list = $true
                        default_value = "Yes\nNo"
                    }
                }
            )
        }
    }
}
New-ITGlueFlexibleAssetTypes -data $data
