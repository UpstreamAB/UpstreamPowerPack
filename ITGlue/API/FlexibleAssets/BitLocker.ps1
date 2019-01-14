$data = @{
    type = 'flexible_asset_types'
    attributes = @{
        name = 'Bitlocker'
        description = 'Bitlocker encryption information and keys.'
        icon = 'lock'
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
                        name = 'Computer'
                        kind = 'Tag'
                        hint = 'Which computer is the drive on?'
                        tag_type = 'Configurations'
                        required = $true
                        show_in_list = $true
                        use_for_title = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 2
                        name = 'Drive'
                        kind = 'Select'
                        default_value = "A:`r`nB:`r`nC:`r`nD:`r`nE:`r`nF:`r`nG:`r`nH:`r`nI:`r`nJ:`r`nK:`r`nL:`r`nM:`r`nN:`r`nO:`r`nP:`r`nQ:`r`nR:`r`nS:`r`nT:`r`nU:`r`nV:`r`nW:`r`nX:`r`nY:`r`nZ:"
                        hint = 'Which drive was encrypted?'
                        required = $true
                        show_in_list = $true
                        use_for_title = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 3
                        name = 'Capacity'
                        kind = 'Text'
                        hint = 'Size of the harddrive.'
                        required = $false
                        show_in_list = $true
                        use_for_title = $true
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 4
                        name = 'Encryption method'
                        kind = 'Text'
                        hint = 'Which encryption method was used to encrypt the drive?'
                        required = $false
                        show_in_list = $true
                        use_for_title = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 5
                        name = 'KeyProtectorId'
                        kind = 'Text'
                        hint = ''
                        tag_type = 'Configurations'
                        required = $true
                        show_in_list = $false
                        use_for_title = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 6
                        name = 'KeyProtectorType'
                        kind = 'Text'
                        hint = ''
                        required = $true
                        show_in_list = $false
                        use_for_title = $false
                    }
                },
                @{
                    type = 'flexible_asset_fields'
                    attributes = @{
                        order = 7
                        name = 'RecoveryPassword'
                        kind = 'Password'
                        hint = ''
                        required = $true
                        show_in_list = $false
                        use_for_title = $false
                    }
                }
            )
        }
    }
}
New-ITGlueFlexibleAssetTypes -data $data