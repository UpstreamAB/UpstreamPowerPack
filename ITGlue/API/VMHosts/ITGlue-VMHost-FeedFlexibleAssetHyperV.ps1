[cmdletbinding()]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='The id of the asset in IT Glue')]
    [long]$flexible_asset_id,

    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='IT Glue api key')]
    $api_key,

    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='Where is your data stored? EU or US?')]
    [ValidateSet('US', 'EU')]
    $data_center
)

# If any parameter is missing
# Cannot use mandatory because it would break setting parameters inside the script.
if(!$flexible_asset_id -or !$api_key -or !$data_center) {
    return "One or more parameter(s) is missing. This script will not continue."
}

# Try to import the IT Glue wrapper module
try{
    Import-Module ITGlueAPI -ErrorAction Stop
} catch [Exception]{
    Write-Output "ITGlueAPI module missing. This script will not continue."
}

# Set API key for this sessions
Add-ITGlueAPIKey -api_key $api_key
# Set data center for this sessions
Add-ITGlueBaseURI -data_center $data_center

# Flexible asset to update
$flexibleAsset = Get-ITGlueFlexibleAssets -id $flexible_asset_id
# The asset's organization id
$organization_id = $flexibleAsset.data.attributes.'organization-id'
# All VMs on the host (with some data)
$VMs = Get-VM

# Hyper-V host's disk information
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

# Support guest OS versions
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

# Virtual swtiches
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

# Virutal machines' disk file locations
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

# Snapshot data
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

# Virutal machines' bios settings
# Generation 1
$vmBiosSettingsTableData = (Get-VMBios * -ErrorAction SilentlyContinue).foreach{
    '<tr>
        <td>{0}</td>
        <td>{1}</td>
        <td>{2}</td>
        <td>Gen 1</td>
    </tr>' -f $_.VMName, ($_.StartupOrder | Out-String).Replace([Environment]::NewLine, ', ').TrimEnd(', '), $_.NumLockEnabled}

# Generation 2
$vmBiosSettingsTableData += (Get-VMFirmware * -ErrorAction SilentlyContinue).foreach{
    '<tr>
        <td>{0}</td>
        <td>{1}</td>
        <td>{2}</td>
        <td>Gen 2</td>
    </tr>' -f $_.VMName, ($_.BootOrder.BootType | Out-String).Replace([Environment]::NewLine, ', ').TrimEnd(', '), 'N/A'}

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

# General information about virtual machines
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
    '<tr>
        <td>{0}</td>
        <td>{1}</td>
        <td>{2}</td>
        <td>{3}</td>
        <td>{4}</td>
    </tr>' -f $_.VMName, $_.AutomaticStartAction, [Math]::Round($_.Memoryassigned/1GB), $_.ProcessorCount, [math]::round($_.FileSize/1GB)} | Out-String)

# Guest NICs and IPs
$guestNICsIPs = '<div>
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

# IT Glue configration ID based on the name of the virtual machine guests
$itgConfigs = (Get-ITGlueConfigurations -organization_id $organization_id).data.where{$VMs.Name -Contains $_.attributes.name}.id

$data = @{
    type = 'flexible-assets'
    attributes = @{
        id = $flexible_asset_id
        traits = @{
            # Visible name
            'vm-host-name' = $flexibleAsset.data.attributes.traits.'vm-host-name'
            # Tagged asset
            'vm-host-it-glue-configuration' = $flexibleAsset.data.attributes.traits.'vm-host-it-glue-configuration'.Values.id
            # Last updated
            'documentation-automation-script-last-queried-this-vm-host-on' = Get-Date -Format 'yyyy-MM-dd HH:mm'
            # Host platform
            'virtualization-platform' = 'Hyper-V'
            # Supported OS versions
            'vm-host-supported-version' = $supportedVersionsHTML
            # Host CPU data
            'cpu' = Get-VMHost | Select -ExpandProperty LogicalProcessorCount
            # Host disk data
            'disk-information' = $diskDataHTML
            # Host RAM data
            'ram' = ((Get-CimInstance CIM_PhysicalMemory).capacity | Measure -Sum).Sum/1GB
            # Virutal network cards (vNIC)
            'virtual-switches' = $virtualSwitchsHTML
            # Custom notes
            'additional-notes' = $flexibleAsset.data.attributes.traits.'additional-notes'
            # Number of VMs on host
            'current-number-of-guests-on-this-vm-host' = ($VMs | measure).Count
            # VMs' name and VHD paths
            'vm-guests-name-s-and-virtual-machine-path-s' = $virtualMachinePathsHTML
            #Snapshop data
            'vm-guest-snapshot-information' = $vmSnapshotHTML
            # VMs' bios settings
            'vm-guests-bios-setting' = $vmBIOSSettingsHTML
            # General VM data (start type, cpu, ram...)
            'general-guest-information' = $guestInformationHTML
            # NIC and IP assigned to each VM
            'virtual-switch-name-and-ip' = $guestNICsIPs

        }
    }
}

Set-ITGlueFlexibleAssets -data $data