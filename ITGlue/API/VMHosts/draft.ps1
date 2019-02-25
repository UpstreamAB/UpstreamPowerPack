[cmdletbinding()]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='The id of the asset in IT Glue')]
    [long]$flexible_asset_id = 988414504894631
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
                <td>Disk name<br></td>
                <td>Total(GB<br>)</td>
                <td>Used(GB)<br></td>
                <td>Free(GB)</td>
            </tr>
            <tr>
                <td>{0}<br></td>
                <td>{1}<br></td>
                <td>{2}<br></td>
                <td>{3}<br></td>
            </tr>
        </tbody>
    </table>
</div>" -f $diskinformation.Root, $diskinformation.'Total(GB)', $diskinformation.'Used(GB)', $diskinformation.'Free(GB)'

$vmswitch = get-vmswitch
$vmswitch_temp = ""
foreach($vms in $vmswitch) {
    $vmswitch_temp += '<tr><td>{0}<br></td><td>{1}<br></td><td>{2}<br></td></tr>' -f $vms.Name, $vms.SwitchType, $vms.NetAdapterInterfaceDescription
}
$vmswitch_formated = '<div>
    <table>
        <tbody>
            <tr>
                <td>Name<br></td>
                <td>Switch type<br></td>
                <td>Interface description<br></td>
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
        $VMs_fromated += '<tr><td>{0}<br></td><td>{1}<br></td></tr>' -f $VM.Name, $path
    }
}


$VMPaths_formated = '<div>
    <table>
        <tbody>
            <tr>
                <td>VM guest name<br></td>
                <td>Path<br></td>
            </tr>
            {0}
        </tbody>
    </table>
</div>' -f $VMs_fromated



$gen1 = get-vmbios * -ErrorAction SilentlyContinue
$gen2 = Get-VMFirmware * -ErrorAction SilentlyContinue

$VMBIOSSettings_tabel_data = ''
$gen1.foreach{$VMBIOSSettings_tabel_data += '<tr><td>{0}<br></td><td>{1}<br></td><td>{2}<br></td><td>Gen 1<br></td></tr>' -f $_.VMName, ("" + $_.StartupOrder).Replace(" ", ", "), $_.NumLockEnabled}
$gen2.foreach{$VMBIOSSettings_tabel_data += '<tr><td>{0}<br></td><td>{1}<br></td><td>{2}<br></td><td>Gen 2<br></td></tr>' -f $_.VMName, ("" + $_.BootOrder.BootType).Replace(" ", ", "), ""}
$VMBIOSSettings_tabel_data

$VMBIOSSettings = '<div>
    <table>
        <tbody>
            <tr>
                <td>VM guest name<br></td>
                <td>Startup order<br></td>
                <td>NumLock enabled<br></td>
                <td>Generation<br></td>
            </tr>
            {0}
        </tbody>
    </table>
</div>' -f $VMBIOSSettings_tabel_data


$guestInfo_tabel_data = ''
$VMs.foreach{
    $guestInfo_tabel_data += '<tr><td>{0}<br></td><td>{1}<br></td><td>{2}<br></td><td>{3}<br></td><td>{4}<br></td></tr>' -f $_.VMName, $_.AutomaticStartAction, [Math]::Round($_.Memoryassigned/1GB), $_.ProcessorCount, [math]::round($_.FileSize/1GB)
}

$guestinfo = '<div>
    <table>
        <tbody>
            <tr>
                <td>VM guest name<br></td>
                <td>Start action<br></td>
                <td>RAM (GB)<br></td>
                <td>vCPU<br></td>
                <td>Size (GB)<br></td>
            </tr>
            {0}
        </tbody>
    </table>
</div>' -f $guestInfo_tabel_data

$guestNICsIP = get-vmnetworkadapter * | Select vmname,switchname,ipaddresses | sort "VMName"

#matchas
$ITGlueVMConfigs = ''

$data = @{
    type = 'flexible-assets'
    attributes = @{
        traits = @{
            'vm-host-name'                      = $asset.data.attributes.traits.'vm-host-name'
            'vm-host-it-glue-configuration'     = $asset.data.attributes.traits.'vm-host-it-glue-configuration'.Values.id
            'documentation-automation-script-last-queried-this-vm-host-on'  = Get-Date -Format "dd-MMM-yyyy HH:mm"
            'virtualization-platform'           = $asset.data.attributes.traits.'virtualization-platform'
            cpu                                 = $VMHost.logicalprocessorcount
            'disk-information'                  = $diskinformation
            ram                                 = ((Get-CimInstance CIM_PhysicalMemory).capacity | Measure -Sum).Sum/1GB
            'virtual-switches'                  = $asset.data.attributes.traits.'virtual-switches'
            'additional-notes'                  = $asset.data.attributes.traits.'additional-notes'
            'vm-guests-virtual-machine-path-s'  = $vmguestsvirtualmachinepaths
            'current-guests-on-this-vm-host'    = ($vms | measure).Count
            'associated-it-glue-configurations' = $ITGlueVMConfigs
            'vm-guests-bios-setting'            = $VMBIOSSettings
            'general-guest-information'         = $guestinfo
            'virtual-switch-name-and-ip'        = $asset.data.attributes.traits.'virtual-switch-name-and-ip'
        }
    }
}