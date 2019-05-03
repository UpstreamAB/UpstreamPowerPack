# Script name: ITGlue-VMHost-CreateFlexibleAsset.ps1
# Script type: Powershell
# Script description: Creates a custom Flexible Asset called "VMHost". Use "ITGlue-VMHost-CreateFlexibleAsset.ps1" to update.
# Dependencies: Powershell 3.0
# Script maintainer: powerpack@upstream.se
# https://en.upstream.se/powerpack/
# --------------------------------------------------------------------------------------------------------------------------------

$data = @{
  type = "flexible_asset_types"
  attributes = @{
    icon = "cubes"
    description = "This Flexible Asset is to be used to automate VM host documentation."
    name = "VM Host"
    enabled = $true
  }
  relationships = @{
    flexible_asset_fields = @{
      data = @(
        @{
          type = "flexible_asset_fields"
          attributes = @{
            order = 1
            name = "VM host name"
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
          attributes = @{
            order = 2
            name = "Documentation automation script last queried this VM host on"
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
          attributes = @{
            order = 3
            name = "VM host configuration"
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
            order = 4
            name = "VM host related IT Glue configuration"
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
          attributes = @{
            order = 5
            name = "Virtualization platform"
            kind = "Select"
            required = $false
            use_for_title = $false
            expiration = $false
            show_in_list = $true
            default_value = "Hyper-V
VMware"
          }
        },
        @{
          type = "flexible_asset_fields"
          attributes = @{
            order = 6
            name = "CPU"
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
          attributes = @{
            order = 7
            name = "RAM"
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
          attributes = @{
            order = 8
            name = "Disk information"
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
          attributes = @{
            order = 9
            name = "Virtual switches"
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
          attributes = @{
            order = 10
            name = "VM Host supported versions"
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
          attributes = @{
            order = 11
            name = "VM guests configuration"
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
            order = 12
            name = "Current number of VM guests on this VM host"
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
          attributes = @{
            order = 13
            name = "VM guest names and information"
            kind = "Textbox"
            hint = "VM guest names vCPUs RAM and other infromation."
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
            order = 14
            name = "VM guest virtual disk paths"
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
          attributes = @{
            order = 15
            name = "VM guests snapshot information"
            kind = "Textbox"
            hint = "All snapshots found on the host"
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
            order = 16
            name = "VM guests BIOS settings"
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
          attributes = @{
            order = 17
            name = "Assigned virtual switches and IP information"
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
          attributes = @{
            order = 18
            name = "This automated documentation is powered by Upstream Power Pack"
            kind = "Header"
            required = $false
            use_for_title = $false
            expiration = $false
            show_in_list = $true
          }
        }
      )
    }
  }
}


New-ITGlueFlexibleAssetTypes -data $data