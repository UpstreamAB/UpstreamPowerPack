#Requires -Modules @{ ModuleName="ITGlueAPI"; ModuleVersion="2.0.7" }


[cmdletbinding()]
param(
    [Parameter(ValueFromPipeline=$true, HelpMessage='The id of the asset in IT Glue')]
    [long]$flexible_asset_id,

    [Parameter(HelpMessage='IT Glue api key')]
    [string]$api_key,

    [Parameter(HelpMessage='Where is your data stored? EU or US?')]
    [ValidateSet('US', 'EU')]
    [string]$data_center
)

Begin {
    Write-Verbose "Start begin block..."

    # Import the IT Glue wrapper module
    Import-Module ITGlueAPI -ErrorAction Stop

    # If any parameter is missing ...
    # (Cannot use mandatory because it would break setting parameters inside the script.)

    if($api_key) {
        # Set API key for this sessions
        Write-Verbose "Using specified API key."
        Add-ITGlueAPIKey -api_key $api_key

    } elseif(!$api_key -and $ITGlue_API_Key) {
        # Use API key imported from module settings
        Write-Verbose "Using API key from module settings already saved."

    } else {
        return "No API key was found or specified, please use -api_key to specify it and run the script again."
    }

    if($data_center) {
        # Set URL for this sessions
        Write-Verbose "Using specified data center $data_center for this session."
        Add-ITGlueBaseURI -data_center $data_center

    } elseif(!$data_center -and $ITGlue_Base_URI) {
        # Use URL imported from module settings
        Write-Verbose "Using URL from module settings already saved."

    } else {
        return "No data center was found or specified, please use -data_center to specify it (US or EU) and run the script again."
    }

    # All below data will always be the same (until the end of the begin block)
    Write-Verbose "Preparing static data."

    # All VMs on the host (with some data)
    $VMs = Get-VM

    # Hyper-V host's disk information
    Write-Verbose "Getting host's disk data..."
    $diskDataHTML = '<div>
        <table>
            <tbody>
                <tr>
                    <td>Disk name</td>
                    <td>Total(GB)</td>
                    <td>Used(GB)</td>
                    <td>Free(GB)</td>
                </tr>
                {0}
            </tbody>
        </table>
    </div>' -f ((Get-PSDrive -PSProvider FileSystem).foreach{
        '<tr>
            <td>{0}</td>
            <td>{1}</td>
            <td>{2}</td>
            <td>{3}</td>
        </tr>' -f $_.Root, [math]::round(($_.free+$_.used)/1GB), [math]::round($_.used/1GB), [math]::round($_.free/1GB)} | Out-String)
    Write-Verbose "Host's disk data done. [1/8]"

    # Support guest OS versions
    Write-Verbose "Getting supported versions..."
    $supportedVersionsHTML = '<div>
        <table>
            <tbody>
                <tr>
                    <td>Name</td>
                    <td>Version</td>
                    <td>Default</td>
                </tr>
                {0}
            </tbody>
        </table>
    </div>' -f ((Get-VMHostSupportedVersion).foreach{
        '<tr>
            <td>{0}</td>
            <td>{1}</td>
            <td>{2}</td>
        </tr>' -f $_.Name, $_.Version, $_.IsDefault} | Out-String)
    Write-Verbose "Supported versions done. [2/8]"

    # Virtual swtiches
    Write-Verbose "Getting virtual swtiches..."
    $virtualSwitchsHTML = '<div>
        <table>
            <tbody>
                <tr>
                    <td>Name</td>
                    <td>Switch type</td>
                    <td>Interface description</td>
                </tr>
                {0}
            </tbody>
        </table>
    </div>' -f ((Get-VMSwitch).foreach{
        '<tr>
            <td>{0}</td>
            <td>{1}</td>
            <td>{2}</td>
        </tr>' -f $_.Name, $_.SwitchType, $_.NetAdapterInterfaceDescription} | Out-String)
    Write-Verbose "Virtual swtiches done. [3/8]"

    # Virutal machines' disk file locations
    Write-Verbose "Getting VM machine paths..."
    $virtualMachinePathsHTML = '<div>
        <table>
            <tbody>
                <tr>
                    <td>VM guest name</td>
                    <td>Path</td>
                </tr>
                {0}
            </tbody>
        </table>
    </div>' -f ($VMs.foreach{
        '<tr>
            <td>{0}</td>
            <td>{1}</td>
        </tr>' -f $_.Name, ((Get-VHD -id $_.id).path | Out-String).Replace([Environment]::NewLine, '<br>').TrimEnd('<br>')} | Out-String)
    Write-Verbose "VM machine paths done. [4/8]"

    # Snapshot data
    Write-Verbose "Getting snapshot data..."
    $vmSnapshotHTML = '<div>
        <table>
            <tbody>
                <tr>
                    <td>VMName</td>
                    <td>Name</td>
                    <td>Snapshot type</td>
                    <td>Creation time</td>
                    <td>Parent snapshot name</td>
                </tr>
                {0}
            </tbody>
        </table>
    </div>' -f ((Get-VMSnapshot -VMName * | Sort VMName, CreationTime).foreach{
        '<tr>
        <td>{0}</td>
        <td>{1}</td>
        <td>{2}</td>
        <td>{3}</td>
        <td>{4}</td>
        </tr>' -f $_.VMName, $_.Name, $_.SnapshotType, $_.CreationTime, $_.ParentSnapshotName} | Out-String)
    Write-Verbose "Snapshot data done. [5/8]"

    # Virutal machines' bios settings
    Write-Verbose "Getting VM BIOS settings..."
    # Generation 1
    $vmBiosSettingsTableData = (Get-VMBios * -ErrorAction SilentlyContinue).foreach{
        '<tr>
            <td>{0}</td>
            <td>{1}</td>
            <td>{2}</td>
            <td>Gen 1</td>
        </tr>' -f $_.VMName, ($_.StartupOrder | Out-String).Replace([Environment]::NewLine, ', ').TrimEnd(', '), $_.NumLockEnabled}
    Write-Verbose "Generation 1 done..."

    # Generation 2
    $vmBiosSettingsTableData += (Get-VMFirmware * -ErrorAction SilentlyContinue).foreach{
        '<tr>
            <td>{0}</td>
            <td>{1}</td>
            <td>{2}</td>
            <td>Gen 2</td>
        </tr>' -f $_.VMName, ($_.BootOrder.BootType | Out-String).Replace([Environment]::NewLine, ', ').TrimEnd(', '), 'N/A'}
    Write-Verbose "Generation 2 done..."

    $vmBIOSSettingsHTML = '<div>
        <table>
            <tbody>
                <tr>
                    <td>VM guest name</td>
                    <td>Startup order</td>
                    <td>NumLock enabled</td>
                    <td>Generation</td>
                </tr>
                {0}
            </tbody>
        </table>
    </div>' -f ($vmBiosSettingsTableData | Out-String)
    Write-Verbose "VM BIOS settings done. [6/8]"

    # General information about virtual machines
    Write-Verbose "Getting general guest information..."
    $guestInformationHTML = '<div>
        <table>
            <tbody>
                <tr>
                    <td>VM guest name</td>
                    <td>Start action</td>
                    <td>RAM (GB)</td>
                    <td>vCPU</td>
                    <td>Size (GB)</td>
                </tr>
                {0}
            </tbody>
        </table>
    </div>' -f ($VMs.foreach{
        $diskSize = 0
        ($_.HardDrives | Get-VHD).FileSize.foreach{$diskSize += $_}
        $diskSize = [Math]::Round($diskSize/1GB)

        '<tr>
            <td>{0}</td>
            <td>{1}</td>
            <td>{2}</td>
            <td>{3}</td>
            <td>{4}</td>
        </tr>' -f $_.VMName, $_.AutomaticStartAction, [Math]::Round($_.MemoryStartup/1GB), $_.ProcessorCount, $diskSize} | Out-String)
    Write-Verbose "General guest information done. [7/8]"

    # Guest NICs and IPs
    Write-Verbose "Getting VM NICs..."
    $guestNICsIPsHTML = '<div>
        <table>
            <tbody>
                <tr>
                    <td>VM guest name</td>
                    <td>Swtich name</td>
                    <td>IP</td>
                </tr>
                {0}
            </tbody>
        </table>
    </div>' -f ((Get-VMNetworkAdapter * | Sort 'VMName').foreach{
        '<tr>
            <td>{0}</td>
            <td>{1}</td>
            <td>{2}</td>
        </tr>' -f $_.vmname, $_.switchname, ($_.ipaddresses | Out-String).Replace([Environment]::NewLine, '<br>').TrimEnd('<br>')} | Out-String)
    Write-Verbose "VM NICs done. [8/8]"


    $data = @{
        type = 'flexible-assets'
        attributes = @{
            traits = @{
                # Last updated
                'documentation-automation-script-last-queried-this-vm-host-on' = Get-Date -Format 'yyyy-MM-dd HH:mm'
                # Host platform
                'virtualization-platform' = 'Hyper-V'
                # Host CPU data
                'cpu' = Get-VMHost | Select -ExpandProperty LogicalProcessorCount
                # Host RAM data
                'ram' = ((Get-CimInstance CIM_PhysicalMemory).capacity | Measure -Sum).Sum/1GB
                # Host disk data
                'disk-information' = $diskDataHTML
                # Virutal network cards (vNIC)
                'virtual-switches' = $virtualSwitchsHTML
                # Supported OS versions
                'vm-host-supported-versions' = $supportedVersionsHTML
                # Number of VMs on host
                'current-number-of-vm-guests-on-this-vm-host' = ($VMs | measure).Count
                # General VM data (start type, cpu, ram...)
                'vm-guest-names-and-information' = $guestInformationHTML
                # VMs' name and VHD paths
                'vm-guest-virtual-disk-paths' = $virtualMachinePathsHTML
                # Snapshop data
                'vm-guests-snapshot-information' = $vmSnapshotHTML
                # VMs' bios settings
                'vm-guests-bios-settings' = $vmBIOSSettingsHTML
                # NIC and IP assigned to each VM
                'assigned-virtual-switches-and-ip-information' = $guestNICsIPsHTML
            }
        }
    }
    Write-Verbose "Finished build hash table."
    Write-Verbose "End of begin block."
}


Process {
    Write-Verbose "Starting process block."
    if(!$flexible_asset_id) {
        return "flexible_asset_id is missing. Please specify it and run the script again. This script will not continue."
    }

    # Flexible asset to update
    Write-Verbose "Retreving IT Glue flexible asset of $flexible_asset_id..."
    $flexibleAsset = Get-ITGlueFlexibleAssets -id $flexible_asset_id
    Write-Verbose "Done."

    # The asset's organization id
    Write-Verbose "Retreving organization id..."
    $organization_id = $flexibleAsset.data.attributes.'organization-id'
    Write-Verbose "Done."

    $data["attributes"]["id"] = $flexible_asset_id
    Write-Verbose "Added id to hash table."
    # Visible name
    $data["attributes"]["traits"]["vm-host-name"] = $flexibleAsset.data.attributes.traits.'vm-host-name'
    Write-Verbose "Added VM host name to hash table."
    # Tagged asset (i.e the host)
    $data["attributes"]["traits"]["vm-host-related-it-glue-configuration"] = $flexibleAsset.data.attributes.traits.'vm-host-related-it-glue-configuration'.Values.id
    Write-Verbose "Added VM host related IT Glue configuration to hash table."

    Write-Verbose "Uploading data for id $flexible_asset_id."
    $resp =  Set-ITGlueFlexibleAssets -data $data
    Write-Verbose "Uploading data: done."
    return $resp
    Write-Verbose "End of process block."
}