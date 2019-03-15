# Script name: ITGlue-VMHost-CreateFlexibleAsset.ps1
# Script type: Powershell
# Script description: Creates a custom Flexible Asset called "VMHost". Use "ITGlue-VMHost-CreateFlexibleAsset.ps1" to update.
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------
$data = @{
  type = "flexible_asset_types"
  Attributes = @{
    icon = "cubes"
    description = "This Flexible Asset is to be used to automate VM host documentation."
    Name = "VM Host"
    enabled = $true
  }
  relationships = @{
    flexible_asset_fields = @{
      data = @(
        @{
          type = "flexible_asset_fields"
          Attributes = @{
            order = 1
            Name = "VM host name"
            kind = "Text"
            hint = "This is the unique name and identifier of this Flexible Asset. It has to match the actual name of the VM Host to be docuemented with the associated Powershell script."
            required = $true
            use_for_title = $true
            expiration = $false
            show_in_list = $true
          }
        },
        @{
          type = "flexible_asset_fields"
          Attributes = @{
            order = 2
            Name = "VM host IT Glue configuration"
            kind = "Tag"
            tag_type = "Configurations"
            required = $true
            use_for_title = $false
            expiration = $false
            show_in_list = $true
          }
        },
        @{
          type = "flexible_asset_fields"
          Attributes = @{
            order = 3
            Name = "Documentation automation script last queried this VM host on"
            kind = "Text"
            hint = "Specifies the last time the VM host was queried for updated documentation."
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
            Name = "VM host configuration"
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
            order = 5
            Name = "Virtualization platform"
            kind = "Select"
            required = $false
            use_for_title = $false
            expiration = $false
            show_in_list = $true
            default_value = "Hyper-V\nVMware"
          }
        },
        @{
          type = "flexible_asset_fields"
          Attributes = @{
            order = 6
            Name = "VM Host supported version"
            kind = "Textbox"
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
            order = 7
            Name = "CPU"
            kind = "Number"
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
            order = 8
            Name = "Disk information"
            kind = "Textbox"
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
            order = 9
            Name = "RAM"
            kind = "Number"
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
            order = 10
            Name = "Virtual switches"
            kind = "Textbox"
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
            order = 11
            Name = "Additional notes"
            kind = "Textbox"
            hint = "Additional notes about this VM host."
            required = $false
            use_for_title = $false
            expiration = $false
            show_in_list = $false
            default_value = "This VM host is automatically documented with API\u0027s. There is a scheduled script checking the VM host once a day for any changes and update the documentation automatically."
          }
        },
        @{
          type = "flexible_asset_fields"
          Attributes = @{
            order = 12
            Name = "VM guest configuration"
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
            order = 13
            Name = "Current number of guests on this VM host"
            kind = "Number"
            hint = "Number of guests detected on this VM host based on latest execution of the ducumentation atutomation script."
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
            order = 14
            Name = "VM guests name(s) and virtual machine path(s)"
            kind = "Textbox"
            hint = "VM guests and virtual disk paths discovered on this VM host."
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
            order = 15
            Name = "VM guests BIOS setting"
            kind = "Textbox"
            hint = "Specifies the BIOS boot settings in each each discovered guest on this VM host."
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
            order = 16
            Name = "General guest information"
            kind = "Textbox"
            hint = "Specifies number of vCPUs RAM and other infromation."
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
            order = 17
            Name = "Virtual switch name and IP"
            kind = "Textbox"
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
            order = 18
            Name = "This automated documentation is powered by Upstream Power Pack"
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