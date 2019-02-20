[cmdletbinding()]
param(
    [Parameter(ValueFromPipelineByPropertyName=$true, HelpMessage='The id of the asset in IT Glue')]
    [long]$flexible_asset_id = 988414504894631
)

$asset = Get-ITGlueFlexibleAssets -id $flexible_asset_id

$hostname = $env:COMPUTERNAME
$VMHost = Get-VMHost
$VMs = Get-VM

# formateras
$diskinformation = Get-psdrive C | Select Root,@{N="Total(GB)";E={""+ [math]::round(($_.free+$_.used)/1GB)}},@{N="Used(GB)";E={""+ [math]::round($_.used/1GB)}},@{N="Free(GB)";E={""+ [math]::round($_.free/1GB)}}
$vmswitch = get-vmswitch
$vmguestsvirtualmachinepaths = ''
$VMBiosData = get-vmbios * + Get-VMFirmware *
$guestinfo = ''
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
            'vm-guests-bios-setting'            = $VMBiosData
            'general-guest-information'         = $guestinfo
            'virtual-switch-name-and-ip'        = $asset.data.attributes.traits.'virtual-switch-name-and-ip'
        }
    }
}