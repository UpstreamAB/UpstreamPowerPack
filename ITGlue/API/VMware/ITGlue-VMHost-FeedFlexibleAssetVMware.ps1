Param(
    [Parameter(Mandatory=$true)]
    [IPAddress]$Server = 10.21.241.50,
    [Parameter(Mandatory=$true)]
    [String]$UserName,
    [Parameter(Mandatory=$true)]
    [String]$Password,
    [Parameter(Mandatory=$true)]
    [Long]$OrganizationID,
    [Parameter(Mandatory=$true)]
    [Long]$FlexibleAssetTypeID
)

# Connect to ESXi
Connect-VIServer -Server $Server -User $UserName -Password $Password


# Page tracker for configurations
$page_number_conf = 1
# First batch IT Glue Configurations
$apicall_conf = Get-ITGlueConfigurations -page_size 100 -filter_organization_id $OrganizationID -page_number $page_number_conf
# Store all configurations here
$ITGlueConfigurations = @()
$ITGlueConfigurations += $apicall_conf.data

# Page tracker for flexible assets
$page_number_asset = 1
# First batch flexible assets
$apicall_asset = Get-ITGlueFlexibleAssets -page_size 100 -filter_organization_id $OrganizationID -filter_flexible_asset_type_id $FlexibleAssetTypeID -page_number $page_number_asset
# Store all assets here
$ITGlueFlexibleAssets = @()
$ITGlueFlexibleAssets += $apicall_asset.data


# Store final asset data here
$assetData = @()

# Get all vm hosts
foreach($VMhost in Get-VMHost) {
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

        # extra data
        ConfigurationId = ''
        AssetId = ''
    }

    # Add data to hash
    $HostNetwork = Get-VMHostNetwork $VMHost
    $Hardware = $VMHost | Get-VMHostHardware
    $VirtualSwitches = $VMHost | Get-VirtualSwitch
    $VMs = $VMHost | Get-VM
    $Storage = $VMHost | Get-VMHostStorage

    $NumberOfGuests = $VMs | Measure | Select -ExpandProperty Count

    # Used for configuration matching
    $VMHostNetwork = Get-VMHostNetwork $VMHost
    $IP = $VMHostNetwork.VirtualNic.IP
    $MAC = $VMHostNetwork.VirtualNic.MAC


    ### IT Glue data ###

    ## Host ##

    # Virtualization platform
    $extractedData.'virtualization-platform' ='VMware Host'

    # VM host hardware information #
    ## Manufacturer, Model, Serial number
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


    # Version
    $extractedData.'version' = $VMhost.Version

    # CPU Cores
    $extractedData.'cpu-cores' = $Hardware.CpuCoreCountTotal

    # RAM (GB)
    $extractedData.'ram-gb'= $VMhost.MemoryTotalGB.ToString('#.#')

    # Disk information
    # $HTMLHash[$VMHost.Name]['disk-information'] = $Storage.FileSystemVolumeInfo | Where Type -ne 'OTHER'
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



    # Virtual switches
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

    ##  Guests ##
    # VM guests information #

    # Current number of VM guests on this VM host
    $extractedData.'current-number-of-vm-guests-on-this-vm-host' = $NumberOfGuests

    # VM guest names and information
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
</div>"
"@

    # VM guest virtual disk paths
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

    # VM guests snapshot information
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

    # VM guests BIOS settings
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

    # Assigned virtual switches and IP information
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

    # Look up host in IT Glue #
    # Clean slate
    $configuration = $null
    # Match host with IT Glue configuration
    $configuration = $ITGlueConfigurations | Where {$_.attributes.'mac-address' -eq $MAC -and $_.attributes.'primary-ip' -eq $IP}

    while(-not $configuration -and $page_number_conf -le $apicall_conf.meta.'total-pages' -and $apicall_conf.links.next) {
        $apicall_conf = Get-ITGlueConfigurations -page_size 100 -filter_organization_id $OrganizationID -page_number ($page_number_conf++)
        $ITGlueConfigurations += $apicall_conf.data

        # Try matching again
        $configuration = $ITGlueConfigurations | Where {$_.attributes.'mac-address' -eq $MAC -and $_.attributes.'primary-ip' -eq $IP}
    }

    # Did we get a match?
    if(-not $configuration) {
        # We did not get a match, creating configuration
        # Type id
        $configurationTypeId = (Get-ITGlueConfigurationTypes -filter_name 'VMware Host').data.id
        if(-not $configurationTypeId) {
            # VMware Host as type was not found, creating
            $configurationTypeId = (New-ITGlueConfigurationTypes -data @{type = 'configuration-types';attributes = @{name = 'VMware Host'}}).data.id
        }

        # Status id
        $configurationStatusId = (Get-ITGlueConfigurationStatuses -filter_name 'Active').data.id

        $configurationData = @{
            type = 'configurations'
            attributes = @{
                name = $extractedData.'vm-host-name'
                organization_id = $OrganizationID
                configuration_type_id = $configurationTypeId
                configuration_status_id = $configurationStatusId
                'primary_ip' = $extractedData.IP
                'mac_address' = $extractedData.MAC
            }
        }

        $configuration = (New-ITGlueConfigurations -data $configurationData).data
    }

    $extractedData.ConfigurationId = $configuration.id


    # Look asset ID #

    # Clean slate
    $flexibleAsset = $null
    # Match configuration ID with IT Glue flexible asset
    $flexibleAsset = $ITGlueFlexibleAssets | Where {$extractedData.ConfigurationId -eq $_.attributes.traits.'vm-host-related-it-glue-configuration'.Values.id}

    while(-not $flexibleAsset -and $page_number_asset -le $apicall_asset.meta.'total-pages' -and $apicall_asset.links.next) {
        $apicall_asset = Get-ITGlueFlexibleAssets -page_size 100 -filter_organization_id $OrganizationID -filter_flexible_asset_type_id $FlexibleAssetTypeID -page_number ($page_number_asset++)
        $ITGlueFlexibleAssets += $apicall_asset.data

        # Try matching again
        $flexibleAsset = $ITGlueFlexibleAssets | Where {$extractedData.ConfigurationId -eq $_.attributes.traits.'vm-host-related-it-glue-configuration'.Values.id}
    }

    # Did we get a match?
    if(-not $flexibleAsset) {
        # We did not get a match, creating flexible asset
        $flexibleAssetData = @{
            type = 'flexible-assets'
            attributes = @{
                'organization-id' = $OrganizationID
                'flexible-asset-type-id' = $FlexibleAssetTypeID
                traits = @{
                    'vm-host-name' = $VMHost.Name
                    'vm-host-related-it-glue-configuration' = $extractedData.ConfigurationId
                }
            }
        }

        $flexibleAsset = (New-ITGlueFlexibleAssets -data $flexibleAssetData).data
    }

    $extractedData.AssetId = $flexibleAsset.id

    $extractedData.'vm-host-name' = $flexibleAsset.attributes.traits.'vm-host-name'
    $extractedData.'vm-host-related-it-glue-configuration' = $extractedData.ConfigurationId

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
                #'force-manual-sync-now' = 'No' # Left out because of destructive API, removes it from asset if not there.
            }
        }
    }

    $update = $false

    if($flexibleAsset.attributes.traits.'force-manual-sync-now' -eq 'Yes') {
        $update = $true
    } elseif($this_assetData.attributes.traits.'vm-host-hardware-information'.replace("`n","").replace("`r","") -ne $flexibleAsset.attributes.traits.'vm-host-hardware-information'.replace("`n","").replace("`r","")) {
        Write-Verbose "Change detected. Will update asset."
        $update = $true
    } elseif($this_assetData.attributes.traits.'version' -ne $flexibleAsset.attributes.traits.'version') {
        Write-Verbose "Change detected. Will update asset."
        $update = $true
    } elseif($this_assetData.attributes.traits.'disk-information'.replace("`n","").replace("`r","") -ne $flexibleAsset.attributes.traits.'disk-information'.replace("`n","").replace("`r","")) {
        Write-Verbose "Change detected. Will update asset."
        $update = $true
    } elseif($this_assetData.attributes.traits.'virtual-switches'.replace("`n","").replace("`r","") -ne $flexibleAsset.attributes.traits.'virtual-switches'.replace("`n","").replace("`r","")) {
        Write-Verbose "Change detected. Will update asset."
        $update = $true
    } elseif($this_assetData.attributes.traits.'current-number-of-vm-guests-on-this-vm-host' -ne $flexibleAsset.attributes.traits.'current-number-of-vm-guests-on-this-vm-host') {
        Write-Verbose "Change detected. Will update asset."
        $update = $true
    } elseif($this_assetData.attributes.traits.'vm-guest-names-and-information'.replace("`n","").replace("`r","") -ne $flexibleAsset.attributes.traits.'vm-guest-names-and-information'.replace("`n","").replace("`r","")) {
        Write-Verbose "Change detected. Will update asset."
        $update = $true
    } elseif($this_assetData.attributes.traits.'vm-guest-virtual-disk-paths'.replace("`n","").replace("`r","") -ne $flexibleAsset.attributes.traits.'vm-guest-virtual-disk-paths'.replace("`n","").replace("`r","")) {
        Write-Verbose "Change detected. Will update asset."
        $update = $true
    } elseif($this_assetData.attributes.traits.'vm-guests-snapshot-information'.replace("`n","").replace("`r","") -ne $flexibleAsset.attributes.traits.'vm-guests-snapshot-information'.replace("`n","").replace("`r","")) {
        Write-Verbose "Change detected. Will update asset."
        $update = $true
    } elseif($this_assetData.attributes.traits.'vm-guests-bios-settings'.replace("`n","").replace("`r","") -ne $flexibleAsset.attributes.traits.'vm-guests-bios-settings'.replace("`n","").replace("`r","")) {
        Write-Verbose "Change detected. Will update asset."
        $update = $true
    } elseif($this_assetData.attributes.traits.'assigned-virtual-switches-and-ip-information'.replace("`n","").replace("`r","") -ne $flexibleAsset.attributes.traits.'assigned-virtual-switches-and-ip-information'.replace("`n","").replace("`r","")) {
        Write-Verbose "Change detected. Will update asset."
        $update = $true
    }

    if($update) {
        $assetData += $this_assetData
    }
}

if(0 -ne $assetData.Count){
    Set-ITGlueFlexibleAssets -data $assetData
} else {
    # Error loggning
}

Disconnect-VIServer -Confirm:$false