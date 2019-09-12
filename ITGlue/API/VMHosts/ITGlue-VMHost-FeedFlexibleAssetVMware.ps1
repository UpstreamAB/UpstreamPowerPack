#Requires -Version 3
#Requires -Modules @{ ModuleName="ITGlueAPI"; ModuleVersion="2.0.5" }

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [IPAddress]$vCenter,
    [Parameter(Mandatory=$true)]
    [String]$UserName,
    [Parameter(Mandatory=$true)]
    [String]$Password,
    [Parameter(Mandatory=$true)]
    [Long]$OrganizationID,
    [Parameter(Mandatory=$true)]
    [Long]$FlexibleAssetTypeID
)

$loggingObject = @{}

# Connect to ESXi
try {
    Write-Verbose "$(Get-Date -format G) Connecting to $vSphereServer."
    $loggingObject['Connection'] = Connect-VIServer -Server $vSphereServer -User $UserName -Password $Password
    Write-Verbose "$(Get-Date -format G) $($loggingObject.Connection | Select Name, Port, IsConnected, User)"
    Write-Verbose "$(Get-Date -format G) Successfully conncected."
} catch {
    Write-Error "Failed to connect to server: $_"
    return
}

# Page tracker for configurations
Write-Verbose "$(Get-Date -format G) Setting page number (configurations) to 1."
$page_number_conf = 1
# First batch IT Glue Configurations
try {
    Write-Verbose "$(Get-Date -format G) Calling the IT Glue API, asking for the first 100 configurations in $OrganizationID."
    $apicall_conf = Get-ITGlueConfigurations -page_size 100 -filter_organization_id $OrganizationID -page_number $page_number_conf -ErrorAction Stop
}catch {
    Write-Verbose "$(Get-Date -format G) Failed to get IT Glue configurations."
    return
}

# Store all configurations here
Write-Verbose "$(Get-Date -format G) Creating an array to store all configurations for future reference."
$ITGlueConfigurations = @()
$ITGlueConfigurations += $apicall_conf.data
Write-Verbose "$(Get-Date -format G) ITGlueConfigurations now has $($ITGlueConfigurations.Count) configurations."

# Page tracker for flexible assets
Write-Verbose "$(Get-Date -format G) Setting page number (flexible assets) to 1."
$page_number_asset = 1
# First batch flexible assets
try {
    Write-Verbose "$(Get-Date -format G) Calling the IT Glue API, asking for the first 100 flexible assets in $OrganizationID with type id $FlexibleAssetTypeID."
    $apicall_asset = Get-ITGlueFlexibleAssets -page_size 100 -filter_organization_id $OrganizationID -filter_flexible_asset_type_id $FlexibleAssetTypeID -page_number $page_number_asset -ErrorAction Stop
}catch {
    Write-Verbose "$(Get-Date -format G) Failed to get IT Glue flexible assets."
    return
}

# Store all assets here
Write-Verbose "$(Get-Date -format G) Creating an array to store all flexible assets for future reference."
$ITGlueFlexibleAssets = @()
$ITGlueFlexibleAssets += $apicall_asset.data
Write-Verbose "$(Get-Date -format G) ITGlueFlexibleAssets now has $($ITGlueFlexibleAssets.Count) flexible assets."


# Store final asset data here
Write-Verbose "$(Get-Date -format G) Creating array to store all final asset data for all assets."
$assetData = @()

# Get all vm hosts
Write-Verbose "$(Get-Date -format G) Looping all VM hosts."
foreach($VMhost in Get-VMHost) {
    Write-Verbose "$(Get-Date -format G) ####### BEGIN NEW HOST #######"
    Write-Verbose "$(Get-Date -format G) Current host's name: $($VMhost.Name)."

    Write-Verbose "$(Get-Date -format G) Creating object to store this hosts data."
    $extractedData = [PSCustomObject]@{
        'vm-host-name' = ''
        'vm-host-related-it-glue-configuration' = ''
        'virtualization-platform' = ''
        'vm-host-hardware-information' = ''
        'version' = ''
        'cpu-cores' = ''
        'ram-gb' = ''
        'disk-information' = ''
        'virtual-switches' = ''
        'current-number-of-vm-guests-on-this-vm-host' = ''
        'vm-guest-names-and-information' = ''
        'vm-guest-virtual-disk-paths' = ''
        'vm-guests-snapshot-information' = ''
        'vm-guests-bios-settings' = ''
        'assigned-virtual-switches-and-ip-information' = ''
        'force-new-revision-next-sync' = ''

        # extra data
        ConfigurationId = ''
        AssetId = ''
    }


    # Add data to hash
    Write-Verbose "$(Get-Date -format G) Asking the host for its network data."
    $HostNetwork = Get-VMHostNetwork $VMHost
    Write-Verbose "$(Get-Date -format G) Asking the host for its hardware data."
    $Hardware = $VMHost | Get-VMHostHardware
    Write-Verbose "$(Get-Date -format G) Asking the host for its virtual switches."
    $VirtualSwitches = $VMHost | Get-VirtualSwitch
    Write-Verbose "$(Get-Date -format G) Asking the host for its virutal machines."
    $VMs = $VMHost | Get-VM
    Write-Verbose "$(Get-Date -format G) Asking the host for its storage data."
    $Storage = $VMHost | Get-VMHostStorage

    $NumberOfGuests = $VMs | Measure | Select -ExpandProperty Count
    Write-Verbose "$(Get-Date -format G) Number of virtual machines: $NumberOfGuests."

    # Used for configuration matching
    $IP = $HostNetwork.VirtualNic.IP
    Write-Verbose "$(Get-Date -format G) IP address: $IP (used for matching)."
    $MAC = $HostNetwork.VirtualNic.MAC
    Write-Verbose "$(Get-Date -format G) MAC address: $MAC (used for matching)."


    # Look up host in IT Glue #
    Write-Verbose "$(Get-Date -format G) Begin matching configuration against IT Glue."
    # Clean slate
    $configuration = $null
    # Match host with IT Glue configuration
    Write-Verbose "$(Get-Date -format G) Looking up the configuration in all retreived."
    $configuration = $ITGlueConfigurations | Where {$_.attributes.'mac-address' -eq $MAC -and $_.attributes.'primary-ip' -eq $IP}

    while(-not $configuration -and $page_number_conf -le $apicall_conf.meta.'total-pages' -and $apicall_conf.links.next) {
        Write-Verbose "$(Get-Date -format G) It was not found and there are more configurations."
        try {
            Write-Verbose "$(Get-Date -format G) Asking for 100 more configurations from IT Glue."
            $apicall_conf = Get-ITGlueConfigurations -page_size 100 -filter_organization_id $OrganizationID -page_number ($page_number_conf++) -ErrorAction Stop
        } catch {
            Write-Error "Failed to get more configurations. Skipping this host."
            continue
        }

        $ITGlueConfigurations += $apicall_conf.data
        Write-Verbose "$(Get-Date -format G) ITGlueConfigurations now has $($ITGlueConfigurations.Count) configurations."

        # Try matching again
        Write-Verbose "$(Get-Date -format G) Looking for the configuration again."
        $configuration = $ITGlueConfigurations | Where {$_.attributes.'mac-address' -eq $MAC -and $_.attributes.'primary-ip' -eq $IP}
    }

    # Did we get a match?
    if(-not $configuration) {
        Write-Verbose "$(Get-Date -format G) The configuration was not found and there are no more configurations in IT Glue."
        Write-Verbose "$(Get-Date -format G) Creating a new configuration."

        # We did not get a match, creating configuration
        # Type id
        Write-Verbose "$(Get-Date -format G) Making sure that 'VMWare Host' is a valid configuration type."
        $configurationTypeId = (Get-ITGlueConfigurationTypes -filter_name 'VMware Host').data.id
        if(-not $configurationTypeId) {
            Write-Verbose "$(Get-Date -format G) 'VMware Host' was not a valid configuration type."
            # VMware Host as type was not found, creating
            try {
                Write-Verbose "$(Get-Date -format G) Creating it now."
                $configurationTypeId = (New-ITGlueConfigurationTypes -data @{type = 'configuration-types';attributes = @{name = 'VMware Host'}} -ErrorAction Stop).data.id
                Write-Verbose "$(Get-Date -format G) Type id: $configurationTypeId."
            } catch {
                Write-Error "Failed to create the configuration type 'VMWare Host': $_. Skipping this host."
                continue
            }
        }

        # Status id
        try {
            Write-Verbose "$(Get-Date -format G) Asking for id of status 'Active'."
            $configurationStatusId = (Get-ITGlueConfigurationStatuses -filter_name 'Active' -ErrorAction Stop).data.id
            Write-Verbose "$(Get-Date -format G) Configuration status id: $configurationStatusId."
        } catch {
            Write-Error "$(Get-Date -format G) Failed to get status id for 'Active'. Skipping this host."
            continue
        }

        Write-Verbose "$(Get-Date -format G) Creating configuration object to upload to IT Glue."
        $configurationData = @{
            type = 'configurations'
            attributes = @{
                name = $VMhost.Name
                organization_id = $OrganizationID
                configuration_type_id = $configurationTypeId
                configuration_status_id = $configurationStatusId
                'primary_ip' = $IP
                'mac_address' = $MAC
            }
        }

        try {
            Write-Verbose "$(Get-Date -format G) Uploading configuration to IT Glue."
            $configuration = (New-ITGlueConfigurations -data $configurationData -ErrorAction Stop).data
            Write-Verbose "$(Get-Date -format G) Successfully uploaded configuration."
        } catch {
            Write-Error "Unable to upload configuration: $_. Skipping this host."
            continue
        }
    }

    $extractedData.ConfigurationId = $configuration.id
    Write-Verbose "$(Get-Date -format G) Configuration id: $($extractedData.ConfigurationId)."
    Write-Verbose "$(Get-Date -format G) This id will be used as related configuration."

    # Look asset ID #

    Write-Verbose "$(Get-Date -format G) Begin matching aginst flexibles asset with this configuration id in IT Glue."
    # Clean slate
    $flexibleAsset = $null
    # Match configuration ID with IT Glue flexible asset
    Write-Verbose "$(Get-Date -format G) Looking up the flexible asset in all retreived."
    $flexibleAsset = $ITGlueFlexibleAssets | Where {$extractedData.ConfigurationId -eq $_.attributes.traits.'vm-host-related-it-glue-configuration'.Values.id}

    while(-not $flexibleAsset -and $page_number_asset -le $apicall_asset.meta.'total-pages' -and $apicall_asset.links.next) {
        Write-Verbose "$(Get-Date -format G) It was not found and there are more flexible assets."
        Write-Verbose "$(Get-Date -format G) Asking for 100 more flexible assets from IT Glue."
        $apicall_asset = Get-ITGlueFlexibleAssets -page_size 100 -filter_organization_id $OrganizationID -filter_flexible_asset_type_id $FlexibleAssetTypeID -page_number ($page_number_asset++)
        $ITGlueFlexibleAssets += $apicall_asset.data
        Write-Verbose "$(Get-Date -format G) ITGlueFlexibleAssets now has $($ITGlueFlexibleAssets.Count) flexible assets."

        # Try matching again
        Write-Verbose "$(Get-Date -format G) Looking for the flexible asset again."
        $flexibleAsset = $ITGlueFlexibleAssets | Where {$extractedData.ConfigurationId -eq $_.attributes.traits.'vm-host-related-it-glue-configuration'.Values.id}
    }

    # Did we get a match?
    if(-not $flexibleAsset) {
        # We did not get a match, creating flexible asset
        Write-Verbose "$(Get-Date -format G) The flexible asset was not found and there are no more flexible assets in IT Glue."
        Write-Verbose "$(Get-Date -format G) Creating a new flexible asset."
        $flexibleAssetData = @{
            type = 'flexible-assets'
            attributes = @{
                'organization-id' = $OrganizationID
                'flexible-asset-type-id' = $FlexibleAssetTypeID
                traits = @{
                    'vm-host-name' = $VMHost.Name
                    'vm-host-related-it-glue-configuration' = $extractedData.ConfigurationId
                    'force-new-revision-next-sync' = 'No'
                }
            }
        }

        try {
            Write-Verbose "$(Get-Date -format G) Uploading flexible asset to IT Glue."
            $flexibleAsset = (New-ITGlueFlexibleAssets -data $flexibleAssetData -ErrorAction Stop).data
            Write-Verbose "$(Get-Date -format G) Successfully uploaded flexible asset."
        } catch {
            Write-Error "Unable to upload flexible asset: $_. Skipping this host."
            continue
        }
    }

    $extractedData.AssetId = $flexibleAsset.id
    Write-Verbose "$(Get-Date -format G) flexible asset id: $($extractedData.ConfigurationId)."

    $extractedData.'force-new-revision-next-sync' = $flexibleAsset.attributes.traits.'force-new-revision-next-sync'
    Write-Verbose "$(Get-Date -format G) Force new revision next sync: $($extractedData.'force-new-revision-next-sync')."


    ### IT Glue data ###
    if($extractedData.AssetId) {
        Write-Verbose "$(Get-Date -format G) Begin constructing IT Glue data."
        ## Host ##

        # Virtualization platform
        $extractedData.'virtualization-platform' = 'VMware Host'
        Write-Verbose "$(Get-Date -format G) [1/16] Virtualization platform: VMware Host"

        # VM host hardware information #
        ## Manufacturer, Model, Serial number
        Write-Verbose "$(Get-Date -format G) VM host hardware information..."
        $extractedData.'vm-host-hardware-information' =
@"
<div>
    <table>
        <tbody>
            <tr>
                <td>Manufacturer</td>
                <td>Model</td>
                <td>SerialNumber</td>
                <td>CPUModel</td>
                <td>CpuCount</td>
                <td>CpuCoreCountTotal</td>
            </tr>
            <tr>
                <td>$($VMhost.Manufacturer)</td>
                <td>$($Hardware.Model)</td>
                <td>$($Hardware.SerialNumber)</td>
                <td>$($Hardware.CPUModel)</td>
                <td>$($Hardware.CpuCount)</td>
                <td>$($Hardware.CpuCoreCountTotal)</td>
            </tr>
        </tbody>
    </table>
</div>
"@

        Write-Verbose "$(Get-Date -format G) [2/16] VM host hardware information done."

        # Version
        $extractedData.'version' = $VMhost.Version
        Write-Verbose "$(Get-Date -format G) [3/16] Version done."

        # CPU Cores
        $extractedData.'cpu-cores' = $Hardware.CpuCoreCountTotal
        Write-Verbose "$(Get-Date -format G) [4/16] CPU cores done."

        # RAM (GB)
        $extractedData.'ram-gb'= $VMhost.MemoryTotalGB.ToString('#.#')
        Write-Verbose "$(Get-Date -format G) [5/16] RAM done."

        # Disk information
        Write-Verbose "$(Get-Date -format G) Disk information..."
        $tableData = ''
        foreach($disk in Get-Datastore) {
            $tableData +="<tr>
                <td>$($disk.Name)</td>
                <td>$($disk.FreeSpaceGB)</td>
                <td>$($disk.CapacityGB)</td>
                <td>$($disk.Datacenter)</td>
                <td>$($disk.Type)</td>
                <td>$($disk.DatastoreBrowserPath)</td>
            </tr>"
        }
        $extractedData.'disk-information' =
@"
<div>
    <table>
        <tbody>
            <tr>
                <td>Disk name</td>
                <td>Free(GB)</td>
                <td>Capacity(GB)</td>
                <td>Datacenter</td>
                <td>Type</td>
                <td>Path</td>
            </tr>
            $tableData
        </tbody>
    </table>
</div>
"@
        Write-Verbose "$(Get-Date -format G) [6/16] Disk information done."



        # Virtual switches
        Write-Verbose "$(Get-Date -format G) Virtual switches..."
        $tableData = ''
        foreach($vswitch in $VirtualSwitches) {
            $tableData += "<tr>
                <td>$($vswitch.Name)</td>
                <td>$($vswitch.VMHost)</td>
                <td>$([String]$vswitch.nic)</td>
            </tr>"
        }
        $extractedData.'virtual-switches' =
@"
<div>
    <table>
        <tbody>
            <tr>
                <td>Name</td>
                <td>VMHost</td>
                <td>Nic</td>
            </tr>
            $tableData
        </tbody>
    </table>
</div>
"@
        Write-Verbose "$(Get-Date -format G) [7/16] Virtual switches done."

        ##  Guests ##
        # VM guests information #

        # Current number of VM guests on this VM host
        $extractedData.'current-number-of-vm-guests-on-this-vm-host' = $NumberOfGuests
        Write-Verbose "$(Get-Date -format G) [8/16] Current number of VM guests on this VM host done."

        # VM guest names and information
        Write-Verbose "$(Get-Date -format G) VM guest names and information..."
        $tableData = ''
        foreach($vm in $VMs) {
            $tableData += "<tr>
                <td>$($vm.Name)</td>
                <td>$($vm.ExtensionData.Config.GuestFullName)</td>
                <td>$($vm.Folder)</td>
                <td>$($vm.HARestartPriority)</td>
                <td>$($vm.MemoryGB.ToString('#'))</td>
                <td>$($vm.Notes)</td>
                <td>$($vm.PowerState)</td>
                <td>$($vm.ResourcePool)</td>
                <td>$($vm.ProvisionedSpaceGB.ToString('#'))</td>
                <td>$($vm.UsedSpaceGB.ToString('#'))</td>
            </tr>"
        }
        $extractedData.'vm-guest-names-and-information' =
@"
<div>
    <table>
        <tbody>
            <tr>
                <td>Name</td>
                <td>OS</td>
                <td>Folder</td>
                <td>HARestartPriority</td>
                <td>MemoryGB</td>
                <td>Notes</td>
                <td>PowerState</td>
                <td>ResourcePool</td>
                <td>ProvisionedSpaceGB</td>
                <td>UsedSpaceGB</td>
            </tr>
            $tableData
        </tbody>
    </table>
</div>
"@
        Write-Verbose "$(Get-Date -format G) [9/16] VM guest names and information done."

        # VM guest virtual disk paths
        Write-Verbose "$(Get-Date -format G) VM guest virtual disk paths..."
        $tableData = ''
        foreach($vmdisk in $($VMs | Get-Harddisk)) {
            $tableData += "<tr>
                <td>$($vmdisk.Parent)</td>
                <td>$($vmdisk.StorageFormat)</td>
                <td>$($vmdisk.DiskType)</td>
                <td>$($vmdisk.Filename)</td>
                <td>$($vmdisk.CapacityGB.ToString('#'))</td>
                <td>$($vmdisk.Persistence)</td>
            </tr>"
        }
        $extractedData.'vm-guest-virtual-disk-paths' =
@"
<div>
    <table>
        <tbody>
            <tr>
                <td>VM guest</td>
                <td>StorageFormat</td>
                <td>DiskType</td>
                <td>Filename</td>
                <td>CapacityGB</td>
                <td>Persistence</td>
            </tr>
            $tableData
        </tbody>
    </table>
</div>
"@
        Write-Verbose "$(Get-Date -format G) [10/16] VM guest virtual disk paths done."

        # VM guests snapshot information
        Write-Verbose "$(Get-Date -format G) VM guests snapshot information..."
        $tableData = ''
        foreach($snapshot in $($VMs | Get-Snapshot)) {
            $tableData += "<tr>
                <td>$($snapshot.VM)</td>
                <td>$($snapshot.Created)</td>
                <td>$($snapshot.ParentSnapshot)</td>
                <td>$($snapshot.Children)</td>
                <td>$($snapshot.SizeGB)</td>
                <td>$($snapshot.PowerState)</td>
            </tr>"
        }
        $extractedData.'vm-guests-snapshot-information' =
@"
<div>
    <table>
        <tbody>
            <tr>
                <td>VM</td>
                <td>Created</td>
                <td>ParentSnapshot</td>
                <td>Children</td>
                <td>SizeGB</td>
                <td>PowerState</td>
            </tr>
            $tableData
        </tbody>
    </table>
</div>
"@
        Write-Verbose "$(Get-Date -format G) [11/16] VM guests snapshot information done."

        # VM guests BIOS settings
        Write-Verbose "$(Get-Date -format G) VM guests BIOS settings..."
        $tableData = ''
        foreach($vm in $VMs) {
            $tableData += "<tr>
                 <td>$($vm.Name)</td>
                 <td>$($vm.ExtensionData.Config.Firmware)</td>
                 <td>$($vm.ExtensionData.Config.BootOptions.EnterBIOSSetup)</td>
                 <td>$($vm.ExtensionData.Config.BootOptions.BootRetryEnabled)</td>
                 <td>$($vm.ExtensionData.Config.BootOptions.BootRetryDelay)</td>
                 <td>$($vm.ExtensionData.Config.BootOptions.BootOrder)</td>
            </tr>"
        }
        $extractedData.'vm-guests-bios-settings' =
@"
<div>
    <table>
        <tbody>
            <tr>
                <td>Name</td>
                <td>Type</td>
                <td>EnterBIOSSetup</td>
                <td>BootRetryEnabled</td>
                <td>BootRetryDelay</td>
                <td>BootOrder</td>
            </tr>
            $tableData
        </tbody>
    </table>
</div>
"@
        Write-Verbose "$(Get-Date -format G) [12/16] VM guests BIOS settings done."

        # Assigned virtual switches and IP information
        Write-Verbose "$(Get-Date -format G) Assigned virtual switches and IP information..."
        $tableData = ''
        foreach($vm in $VMs) {
            $nic = Get-NetworkAdapter -VM $vm
            $tableData += "<tr>
                <td>$($vm.Name)</td>
                <td>$($nic.Name)</td>
                <td>$($nic.NetworkName)</td>
                <td>$($nic.WakeOnLanEnabled)</td>
                <td>$($nic.Type)</td>
                <td>$($nic.ConnectionState.Connected)</td>
                <td>$($nic.ConnectionState.StartConnected)</td>
                <td>$($nic.ConnectionState.AllowGuestControl)</td>
            </tr>"
        }
        $extractedData.'assigned-virtual-switches-and-ip-information' =
@"
<div>
    <table>
        <tbody>
            <tr>
                <td>VM guest name</td>
                <td>Adapter name</td>
                <td>NetworkName</td>
                <td>WakeOnLanEnabled</td>
                <td>Type</td>
                <td>Connected</td>
                <td>StartConnected</td>
                <td>AllowGuestControl</td>
            </tr>
            $tableData
        </tbody>
    </table>
</div>
"@
        Write-Verbose "$(Get-Date -format G) [13/16] Assigned virtual switches and IP information done."


        $extractedData.'vm-host-name' = $flexibleAsset.attributes.traits.'vm-host-name'
        Write-Verbose "$(Get-Date -format G) [14/16] VM host name done."
        $extractedData.'vm-host-related-it-glue-configuration' = $extractedData.ConfigurationId
        Write-Verbose "$(Get-Date -format G) [15/16] VM host related it glue configuration done."

        Write-Verbose "$(Get-Date -format G) Constructing flexible asset data..."
        $this_assetData = @{
            type = 'flexible-assets'
            attributes = @{
                id = $extractedData.AssetId
                traits = @{
                    'vm-host-name' = $extractedData.'vm-host-name'
                    'vm-host-related-it-glue-configuration' = $extractedData.'vm-host-related-it-glue-configuration'
                    'virtualization-platform' = $extractedData.'virtualization-platform'
                    'vm-host-hardware-information' = $extractedData.'vm-host-hardware-information'
                    'version' = $extractedData.'version'
                    'cpu-cores' = $extractedData.'cpu-cores'
                    'ram-gb' = $extractedData.'ram-gb'
                    'disk-information' = $extractedData.'disk-information'
                    'virtual-switches' = $extractedData.'virtual-switches'
                    'current-number-of-vm-guests-on-this-vm-host' = $extractedData.'current-number-of-vm-guests-on-this-vm-host'
                    'vm-guest-names-and-information' = $extractedData.'vm-guest-names-and-information'
                    'vm-guest-virtual-disk-paths' = $extractedData.'vm-guest-virtual-disk-paths'
                    'vm-guests-snapshot-information' = $extractedData.'vm-guests-snapshot-information'
                    'vm-guests-bios-settings' = $extractedData.'vm-guests-bios-settings'
                    'assigned-virtual-switches-and-ip-information' = $extractedData.'assigned-virtual-switches-and-ip-information'
                    'force-new-revision-next-sync' = $extractedData.'force-new-revision-next-sync'
                }
            }
        }
        Write-Verbose "$(Get-Date -format G) [16/16] Constructing flexible asset data done."

        $update = $false

        Write-Verbose "$(Get-Date -format G) Compare old data with new data to find any changes..."
        if($flexibleAsset.attributes.traits.'force-new-revision-next-sync' -eq 'Yes') {
            Write-Verbose "$(Get-Date -format G) Force update detected. Will update asset."
            $update = $true
        } elseif($this_assetData.attributes.traits.'vm-host-hardware-information'.replace("`n","").replace("`r","") -ne ($flexibleAsset.attributes.traits.'vm-host-hardware-information' -replace"`n","" -replace"`r","")) {
            Write-Verbose "$(Get-Date -format G) Change detected: vm host hardware information. Will update asset."
            $update = $true
        } elseif($this_assetData.attributes.traits.'version' -ne $flexibleAsset.attributes.traits.'version') {
            Write-Verbose "$(Get-Date -format G) Change detected: verison. Will update asset."
            $update = $true
        } elseif($this_assetData.attributes.traits.'disk-information'.replace("`n","").replace("`r","") -ne ($flexibleAsset.attributes.traits.'disk-information' -replace"`n","" -replace"`r","")) {
            Write-Verbose "$(Get-Date -format G) Change detected: disk information. Will update asset."
            $update = $true
        } elseif($this_assetData.attributes.traits.'virtual-switches'.replace("`n","").replace("`r","") -ne ($flexibleAsset.attributes.traits.'virtual-switches' -replace"`n","" -replace"`r","")) {
            Write-Verbose "$(Get-Date -format G) Change detected: virutal switches. Will update asset."
            $update = $true
        } elseif($this_assetData.attributes.traits.'current-number-of-vm-guests-on-this-vm-host' -ne ($flexibleAsset.attributes.traits.'current-number-of-vm-guests-on-this-vm-host')) {
            Write-Verbose "$(Get-Date -format G) Change detected: number of vm guests. Will update asset."
            $update = $true
        } elseif($this_assetData.attributes.traits.'vm-guest-names-and-information'.replace("`n","").replace("`r","") -ne ($flexibleAsset.attributes.traits.'vm-guest-names-and-information' -replace"`n","" -replace"`r","")) {
            Write-Verbose "$(Get-Date -format G) Change detected: vm guest name and information. Will update asset."
            $update = $true
        } elseif($this_assetData.attributes.traits.'vm-guest-virtual-disk-paths'.replace("`n","").replace("`r","") -ne ($flexibleAsset.attributes.traits.'vm-guest-virtual-disk-paths' -replace"`n","" -replace"`r","")) {
            Write-Verbose "$(Get-Date -format G) Change detected: vm guest virutal disk paths. Will update asset."
            $update = $true
        } elseif($this_assetData.attributes.traits.'vm-guests-snapshot-information'.replace("`n","").replace("`r","") -ne ($flexibleAsset.attributes.traits.'vm-guests-snapshot-information' -replace"`n","" -replace"`r","")) {
            Write-Verbose "$(Get-Date -format G) Change detected: vm guest snapshot information. Will update asset."
            $update = $true
        } elseif($this_assetData.attributes.traits.'vm-guests-bios-settings'.replace("`n","").replace("`r","") -ne ($flexibleAsset.attributes.traits.'vm-guests-bios-settings' -replace"`n","" -replace"`r","")) {
            Write-Verbose "$(Get-Date -format G) Change detected: vm guest bios settings. Will update asset."
            $update = $true
        } elseif($this_assetData.attributes.traits.'assigned-virtual-switches-and-ip-information'.replace("`n","").replace("`r","") -ne ($flexibleAsset.attributes.traits.'assigned-virtual-switches-and-ip-information' -replace"`n","" -replace"`r","")) {
            Write-Verbose "$(Get-Date -format G) Change detected: assigned virtual switches and ip information. Will update asset."
            $update = $true
        }

        if($update) {
            Write-Verbose "$(Get-Date -format G) Adding this (host: $($VMhost.Name)) asset data to final asset data for upload."
            $assetData += $this_assetData
        } else {
            Write-Verbose "$(Get-Date -format G) No change detected. This asset will not be updated."
        }
    }
}

Write-Verbose "$(Get-Date -format G) Number of assets to update: $($assetData.Count)"
if(0 -ne $assetData.Count){
    Write-Verbose "$(Get-Date -format G) These hosts will be updated:"
    foreach($name in $assetData.attributes.traits.'vm-host-name') {
        Write-Verbose "$(Get-Date -format G) $name"
    }

    try {
        Write-Verbose "$(Get-Date -format G) Uploading final asset data to IT Glue"
        $loggingObject['flexible_asset'] = Set-ITGlueFlexibleAssets -data $assetData
        Write-Verbose "$(Get-Date -format G) Upload complete."
    } catch {
        Write-Error "Unable to upload data to IT Glue: $_"
        return
    }
} else {
    Write-Verbose "$(Get-Date -format G) No flexible assets to update."
}

Write-Verbose "$(Get-Date -format G) Disconnecting."
Disconnect-VIServer -Server $loggingObject.Connection -Confirm:$false