Param(
    [Parameter(Mandatory=$true]
    [IPAddress]$Server,
    [Parameter(Mandatory=$true]
    [String]$UserName,
    [Parameter(Mandatory=$true]
    [String]$Password,
    [Parameter(Mandatory=$true]
    [Long]$OrganizationID
)

# Connect to ESXi
Connect-VIServer -Server $Server -User $UserName -Password $Password


$HTMLHash = @{}
$data = @()

# Get all vm hosts
foreach($VMhost in Get-VMHost) {
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
    $HTMLHash[$VMHost.Name] = @{}

    ## Host ##
    # * VM host name
    $HTMLHash[$VMHost.Name]['vm-host-name'] = $VMHost.Name
    # * VM host related IT Glue configuration
    $HTMLHash[$VMHost.Name]['vm-host-related-it-glue-configuration'] = 1238967020437639
    # Virtualization platform
    $HTMLHash[$VMHost.Name]['virtualization-platform'] ='VMware'

    # VM host hardware information #
    ## Manufacturer, Model, Serial number
    $HTMLHash[$VMHost.Name]['vm-host-hardware-information'] =
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
    $HTMLHash[$VMHost.Name]['version'] = $VMhost.Version

    # CPU Cores
    $HTMLHash[$VMHost.Name]['cpu-cores'] = $Hardware.CpuCount
    $Hardware.CpuCoreCountTotal

    # RAM (GB)
    $HTMLHash[$VMHost.Name]['ram-gb'] = $VMhost.MemoryTotalGB.ToString('#.#')

    # Disk information
    # $HTMLHash[$VMHost.Name]['disk-information'] = $Storage.FileSystemVolumeInfo | Where Type -ne 'OTHER'
    $table_data = ''
    foreach($disk in Get-Datastore) {
        $table_data +="<tr>
            <td>$($disk.Name)</td>
            <td>$($disk.FreeSpaceGB)</td>
            <td>$($disk.CapacityGB)</td>
            <td>$($disk.Datacenter)</td>
            <td>$($disk.Type)</td>
            <td>$($disk.DatastoreBrowserPath)</td>
        </tr>"
    }
        $HTMLHash[$VMHost.Name]['disk-information'] =
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
            $table_data
        </tbody>
    </table>
</div>
"@



    # Virtual switches
    $table_data = ''
    foreach($vswitch in $VirtualSwitches) {
        $table_data += "<tr>
            <td>$($vswitch.Name)</td>
            <td>$($vswitch.VMHost)</td>
            <td>$([String]$vswitch.nic)</td>
        </tr>"
    }
        $HTMLHash[$VMHost.Name]['virtual-switches'] =
@"
<div>
    <table>
        <tbody>
            <tr>
                <td>Name</td>
                <td>VMHost</td>
                <td>Nic</td>
            </tr>
            $table_data
        </tbody>
    </table>
</div>
"@

    ##  Guests ##
    # VM guests information #

    # Current number of VM guests on this VM host
    $HTMLHash[$VMHost.Name]['Current number of VM guests on this VM host'] = $NumberOfGuests

    # VM guest names and information
    $table_data = ''
    foreach($vm in $VMs) {
        $table_data += "<tr>
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
    $HTMLHash[$VMHost.Name]['vm-guest-names-and-information'] =
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
            $table_data
        </tbody>
    </table>
</div>"
"@

    # VM guest virtual disk paths
    $table_data = ''
    foreach($vmdisk in $($VMs | Get-Harddisk)) {
        $table_data += "<tr>
            <td>$($vmdisk.Parent)</td>
            <td>$($vmdisk.StorageFormat)</td>
            <td>$($vmdisk.DiskType)</td>
            <td>$($vmdisk.Filename)</td>
            <td>$($vmdisk.CapacityGB.ToString('#'))</td>
            <td>$($vmdisk.Persistence)</td>
        </tr>"
    }
    $HTMLHash[$VMHost.Name]['vm-guest-virtual-disk-paths'] =
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
            $table_data
        </tbody>
    </table>
</div>
"@

    # VM guests snapshot information
    $table_data = ''
    foreach($snapshot in $($VMs | Get-Snapshot)) {
        $table_data += "<tr>
            <td>$($snapshot.VM)</td>
            <td>$($snapshot.Created)</td>
            <td>$($snapshot.ParentSnapshot)</td>
            <td>$($snapshot.Children)</td>
            <td>$($snapshot.SizeGB)</td>
            <td>$($snapshot.PowerState)</td>
        </tr>"
    }
        $HTMLHash[$VMHost.Name]['vm-guests-snapshot-information'] =
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
            $table_data
        </tbody>
    </table>
</div>
"@

    # VM guests BIOS settings
    $table_data = ''
    foreach($vm in $VMs) {
        $table_data = '<tr>'
        $table_data += "<td>$($vm.Name)</td>"
        $table_data += "<td>$($vm.ExtensionData.Config.Firmware)</td>"
        $table_data += "<td>$($vm.ExtensionData.Config.BootOptions.EnterBIOSSetup)</td>"
        $table_data += "<td>$($vm.ExtensionData.Config.BootOptions.BootRetryEnabled)</td>"
        $table_data += "<td>$($vm.ExtensionData.Config.BootOptions.BootRetryDelay)</td>"
        $table_data += "<td>$($vm.ExtensionData.Config.BootOptions.BootOrder)</td>"
        $table_data = '</tr>'
    }

    $HTMLHash[$VMHost.Name]['vm-guests-bios-settings'] =
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
            $table_data
        </tbody>
    </table>
</div>
"@

    # Assigned virtual switches and IP information
    $table_data = ''
    foreach($vm in $VMs) {
        $nic = Get-NetworkAdapter -VM $vm
        $table_data += "<tr>
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
    $HTMLHash[$VMHost.Name]['assigned-virtual-switches-and-ip-information'] =
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
                <tdTypetd>
                <td>Connected</td>
                <td>StartConnected</td>
                <td>AllowGuestControl</td>
            </tr>
            $table_data
        </tbody>
    </table>
</div>
"@

    $data += @{
        type = 'flexible-assets'
        attributes = @{
            id = 1270161852465389
            traits = @{
                'vm-host-name' = $VMHost.Name
                'vm-host-related-it-glue-configuration' = 1270160615194765, 1270160536830091
                'virtualization-platform' = 'VMWare'
                'vm-host-hardware-information' = $HTMLHash[$VMHost.Name]['vm-host-hardware-information']
                'version' = $HTMLHash[$VMHost.Name]['version']
                'cpu-cores' = $HTMLHash[$VMHost.Name]['cpu-cores']
                'ram-gb' = $HTMLHash[$VMHost.Name]['ram-gb']
                'disk-information' = $HTMLHash[$VMHost.Name]['disk-information']
                'virtual-switches' = $HTMLHash[$VMHost.Name]['virtual-switches']
                'current-number-of-vm-guests-on-this-vm-host' = $HTMLHash[$VMHost.Name]['current-number-of-vm-guests-on-this-vm-host']
                'vm-guest-names-and-information' = $HTMLHash[$VMHost.Name]['vm-guest-names-and-information']
                'vm-guest-virtual-disk-paths' = $HTMLHash[$VMHost.Name]['vm-guest-virtual-disk-paths']
                'vm-guests-snapshot-information' = $HTMLHash[$VMHost.Name]['vm-guests-snapshot-information']
                'vm-guests-bios-settings' = $HTMLHash[$VMHost.Name]['vm-guests-bios-settings']
                'assigned-virtual-switches-and-ip-information' = $HTMLHash[$VMHost.Name]['assigned-virtual-switches-and-ip-information']
            }
        }
    }

    break;
}

Set-ITGlueFlexibleAssets -data $data
Disconnect-VIServer -Confirm:$false