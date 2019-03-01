﻿[cmdletbinding()]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='The id of the asset in IT Glue')]
    [long]$flexible_asset_id,

    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='IT Glue api key')]
    $api_key,

    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='Where is your data stored? EU or US?')]
    [ValidateSet('US', 'EU')]
    $data_center
)

if(!$flexible_asset_id -or !$api_key -or !$data_center) {
    return "One or more parameter(s) is missing. This script will not continue."
}

try{
    Import-Module ITGlueAPI -ErrorAction Stop
} catch [Exception]{
    Write-Output "ITGlueAPI module missing. This script will not continue."
}

Add-ITGlueAPIKey -api_key $api_key
Add-ITGlueBaseURI -data_center $data_center

$flexibleAsset = Get-ITGlueFlexibleAssets -id $flexible_asset_id
$organization_id = $flexibleAsset.data.attributes.'organization-id'
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
</div>' -f ((Get-PSDrive -PSProvider FileSystem).foreach{'<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>' -f $_.Root, [math]::round(($_.free+$_.used)/1GB), [math]::round($_.used/1GB), [math]::round($_.free/1GB)} | Out-String)

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
</div>' -f ((Get-VMHostSupportedVersion).foreach{'<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>' -f $_.Name, $_.Version, $_.IsDefault} | Out-String)

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
</div>' -f ((Get-VMSwitch).foreach{'<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>' -f $_.Name, $_.SwitchType, $_.NetAdapterInterfaceDescription} | Out-String)

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
</div>' -f ($VMs.foreach{'<tr><td>{0}</td><td>{1}</td></tr>' -f $_.Name, ((Get-VHD -id $_.id).path | Out-String).Replace([Environment]::NewLine, '<br>').TrimEnd('<br>')} | Out-String)

# Virutal machines' bios settings
# Generation 1
$vmBiosSettingsTableData = (Get-VMBios * -ErrorAction SilentlyContinue).foreach{'<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>Gen 1</td></tr>' -f $_.VMName, ($_.StartupOrder | Out-String).Replace([Environment]::NewLine, '<br>').TrimEnd('<br>'), $_.NumLockEnabled}
# Generation 2
$vmBiosSettingsTableData += (Get-VMFirmware * -ErrorAction SilentlyContinue).foreach{'<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>Gen 2</td></tr>' -f $_.VMName, ($_.BootOrder.BootType | Out-String).Replace([Environment]::NewLine, '<br>').TrimEnd('<br>'), 'N/A'}
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
</div>' -f ($VMs.foreach{'<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>' -f $_.VMName, $_.AutomaticStartAction, [Math]::Round($_.Memoryassigned/1GB), $_.ProcessorCount, [math]::round($_.FileSize/1GB)} | Out-String)

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
</div>' -f ((Get-VMNetworkAdapter * | Sort 'VMName').foreach{'<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>' -f $_.vmname, $_.switchname, ($_.ipaddresses | Out-String).Replace([Environment]::NewLine, '<br>').TrimEnd('<br>')} | Out-String)

# IT Glue configration ID based on the name of the virtual machine guests
$itgConfigs = (Get-ITGlueConfigurations -organization_id $organization_id).data.where{$VMs.Name -Contains $_.attributes.name}.id

$data = @{
    type = 'flexible-assets'
    attributes = @{
        id = $flexible_asset_id
        traits = @{
            'disk-information'                  = $diskDataHTML
            'vm-host-supported-version'         = $supportedVersionsHTML
            'virtual-switches'                  = $virtualSwitchsHTML
            'vm-guests-virtual-machine-path-s'  = $virtualMachinePathsHTML
            'vm-guests-bios-setting'            = $vmBIOSSettingsHTML
            'general-guest-information'         = $guestInformationHTML
            'virtual-switch-name-and-ip'        = $guestNICsIPs

            'vm-host-it-glue-configuration'     = $flexibleAsset.data.attributes.traits.'vm-host-it-glue-configuration'.Values.id

            'vm-host-name'                      = $flexibleAsset.data.attributes.traits.'vm-host-name'
            'additional-notes'                  = $flexibleAsset.data.attributes.traits.'additional-notes'
            'associated-it-glue-configurations' = $itgConfigs

            'virtualization-platform'           = 'Hyper-V'
            'cpu'                               = Get-VMHost | Select -ExpandProperty LogicalProcessorCount
            'ram'                               = ((Get-CimInstance CIM_PhysicalMemory).capacity | Measure -Sum).Sum/1GB
            'current-guests-on-this-vm-host'    = ($VMs | measure).Count

            'documentation-automation-script-last-queried-this-vm-host-on' = Get-Date -Format 'dd-MMM-yyyy HH:mm'
        }
    }
}

Set-ITGlueFlexibleAssets -data $data