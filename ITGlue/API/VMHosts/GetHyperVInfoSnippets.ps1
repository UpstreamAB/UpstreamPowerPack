# Saker att använda i IT Glue integartionen

# Senast updaterad dag & datum
Get-Date -Format "dd-MMM-yyyy HH:mm"

# Visa VM host supportade versioner
Get-VMHostSupportedVersion

# Hämta VM host namn
Get-VMHost | Select @{Name="VHostName";Expression={$_."Name"}}

# Hämta VM host RAM 
Get-VMHost | Select @{N="Total RAM(GB)";E={""+ [math]::round($_.Memorycapacity/1GB)}}

# Hämta VM host logiska CPU
Get-VMHost | Select logicalprocessorcount

# Hämta lista på VM guests
Get-VM

echo "VHOST Server IP Addresses and NIC's" | out-file $file -append
Get-WMIObject win32_NetworkAdapterConfiguration |   Where-Object { $_.IPEnabled -eq $true } | Select IPAddress,Description | format-table -autosize | out-file $file -append

# Hämta VM host diskinformation
Get-psdrive C | Select Root,@{N="Total(GB)";E={""+ [math]::round(($_.free+$_.used)/1GB)}},@{N="Used(GB)";E={""+ [math]::round($_.used/1GB)}},@{N="Free(GB)";E={""+ [math]::round($_.free/1GB)}}

# Hämta VM host virutal switches
get-vmswitch

# Hämta VM hosts virtual NIC's
get-vmnetworkadapter * | Select vmname,switchname,ipaddresses | sort "VMName"

# Hämta info om VM guests BIOS settings
get-vmbios *  | sort "VMName"

# Hämta info om VM guests Snapshots
get-vmsnapshot

# Lista info om varje VM guest
$outputArray = @()
foreach($VM in $VMS)
    { 
      $VMsRAM = [math]::round($VM.Memoryassigned/1GB)
      $VMsCPU = $VM.processorCount
      $VMsState = $VM.State
      $VMsStatus = $VM.Status
      $VMsUptime = $VM.Uptime
      $VMsAutomaticstartaction = $VM.Automaticstartaction
      $VMsIntegrationServicesVersion = $VM.IntegrationServicesVersion
      $VMsReplicationState = $VM.ReplicationState
      $VHDs = Get-VHD -VMId $VM.VMiD
      $VHDsGB = [math]::round($VHDs.FileSize/1GB)
      $VMDVD = Get-vmdvddrive -VMname $VM.VMname
    
      $output = new-object psobject
      $output | add-member noteproperty "VM Name" $VM.Name
      $output | add-member noteproperty "RAM(GB)" $VMsRAM
      $output | add-member noteproperty "vCPU" $VMsCPU
      $output | add-member noteproperty "State" $VMsState
      $output | add-member noteproperty "Status" $VMsStatus
      $output | add-member noteproperty "Uptime" $VMsUptime
      $output | add-member noteproperty "Start Action" $VMsAutomaticstartaction
      $output | add-member noteproperty "Integration Tools" $VMsIntegrationServicesVersion
      $output | add-member noteproperty "Replication State" $VMsReplicationState
      $output | add-member noteproperty "VHD Path" $VHDs.Path
      $output | add-member noteproperty "Size GB" $VHDsGB
      $output | add-member noteproperty "VHD Type" $VHDs.vhdtype
      $output | add-member noteproperty "VHD Format" $VHDs.vhdformat
      $output | add-member noteproperty "DVD Media Type" $VMDVD.dvdmediatype
      $output | add-member noteproperty "DVD Media Path" $VMDVD.path
      $outputArray += $output
     }
