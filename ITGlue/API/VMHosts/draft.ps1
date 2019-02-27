[cmdletbinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, HelpMessage='The id of the asset in IT Glue')]
    [long]$flexible_asset_id
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, HelpMessage='The id of the organization in IT Glue')]
    [long]$organization_id
)

$asset = Get-ITGlueFlexibleAssets -id $flexible_asset_id

$hostname = $env:COMPUTERNAME
$VMHost = Get-VMHost

# formateras
$diskinformation = Get-psdrive C | Select Root,@{N="Total(GB)";E={""+ [math]::round(($_.free+$_.used)/1GB)}},@{N="Used(GB)";E={""+ [math]::round($_.used/1GB)}},@{N="Free(GB)";E={""+ [math]::round($_.free/1GB)}}
$diskinformation_formated = "<div>
    <table>
        <tbody>
            <tr>
                <td>Disk name</td>
                <td>Total(GB)</td>
                <td>Used(GB)</td>
                <td>Free(GB)</td>
            </tr>
            <tr>
                <td>{0}</td>
                <td>{1}</td>
                <td>{2}</td>
                <td>{3}</td>
            </tr>
        </tbody>
    </table>
</div>" -f $diskinformation.Root, $diskinformation.'Total(GB)', $diskinformation.'Used(GB)', $diskinformation.'Free(GB)'

$supportedVersion_table_data = ''
$supportedVersion_table_data += (Get-VMHostSupportedVersion).foreach{'<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>' -f $_.Name, $_.Version, $_.IsDefault}
$supportedVersion_formated = '<div>
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
</div>' -f $supportedVersion_table_data



$vmswitch = get-vmswitch
$vmswitch_temp = ""
foreach($vms in $vmswitch) {
    $vmswitch_temp += '<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>' -f $vms.Name, $vms.SwitchType, $vms.NetAdapterInterfaceDescription
}
$vmswitch_formated = '<div>
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
</div>' -f $vmswitch_temp

#vm guests virtual machine paths
$VMs_fromated = ""
$VMs = Get-VM
foreach($VM in $VMs) {
    $paths = $VM | Select Id | Get-VHD
    foreach($path in $paths.Path) {
        $VMs_fromated += '<tr><td>{0}</td><td>{1}</td></tr>' -f $VM.Name, $path
    }
}
$VMPaths_formated = '<div>
    <table>
        <tbody>
            <tr>
                <td>VM guest name</td>
                <td>Path</td>
            </tr>
            {0}
        </tbody>
    </table>
</div>' -f $VMs_fromated



$gen1 = get-vmbios * -ErrorAction SilentlyContinue
$gen2 = Get-VMFirmware * -ErrorAction SilentlyContinue

$VMBIOSSettings_tabel_data = ''
$gen1.foreach{$VMBIOSSettings_tabel_data += '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>Gen 1</td></tr>' -f $_.VMName, ("" + $_.StartupOrder).Replace(" ", ", "), $_.NumLockEnabled}
$gen2.foreach{$VMBIOSSettings_tabel_data += '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>Gen 2</td></tr>' -f $_.VMName, ("" + $_.BootOrder.BootType).Replace(" ", ", "), ""}

$VMBIOSSettings = '<div>
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
</div>' -f $VMBIOSSettings_tabel_data


$guestInfo_tabel_data = ''
$VMs.foreach{
    $guestInfo_tabel_data += '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>' -f $_.VMName, $_.AutomaticStartAction, [Math]::Round($_.Memoryassigned/1GB), $_.ProcessorCount, [math]::round($_.FileSize/1GB)
}

$guestinfo = '<div>
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
</div>' -f $guestInfo_tabel_data

$guestNICsIP_table_data = ''
(get-vmnetworkadapter * | sort "VMName").foreach{
    $guestNICsIP_table_data += '<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>' -f $_.vmname, $_.switchname, ("" + $_.ipaddresses).Replace(" ", ", ")
}

$guestNICsIP = '<div>
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
</div>' -f $guestNICsIP_table_data



#matchas
$itgConfigs = Get-ITGlueConfigurations -organization_id $organization_id
$ITGlueVMConfigs = $itgConfigs.data.where{$VMs.Name -Contains $_.attributes.name}.id


$data = @{
    type = 'flexible-assets'
    attributes = @{
        id = $flexible_asset_id
        traits = @{
            'vm-host-name'                                                  = $asset.data.attributes.traits.'vm-host-name' + " draft"
            'vm-host-it-glue-configuration'                                 = $ITGlueVMConfigs
            'documentation-automation-script-last-queried-this-vm-host-on'  = Get-Date -Format "dd-MMM-yyyy HH:mm"
            'virtualization-platform'                                       = 'Hyper-V'
            cpu                                                             = $VMHost.logicalprocessorcount
            'disk-information'                                              = $diskinformation_formated
            ram                                                             = ((Get-CimInstance CIM_PhysicalMemory).capacity | Measure -Sum).Sum/1GB
            'virtual-switches'                                              = $vmswitch_formated
            'vm-host-supported-version'                                     = $supportedVersion_formated
            'additional-notes'                                              = $asset.data.attributes.traits.'additional-notes'
            'vm-guests-virtual-machine-path-s'                              = $VMPaths_formated
            'current-guests-on-this-vm-host'                                = ($VMs | measure).Count
            'associated-it-glue-configurations'                             = $ITGlueVMConfigs
            'vm-guests-bios-setting'                                        = $VMBIOSSettings
            'general-guest-information'                                     = $guestinfo
            'virtual-switch-name-and-ip'                                    = $guestNICsIP
        }
    }
}

Set-ITGlueFlexibleAssets -data $data