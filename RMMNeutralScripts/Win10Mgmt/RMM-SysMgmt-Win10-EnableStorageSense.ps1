<#
=================================================================================
Filename:           RMM-SysMgmt-Win10-EnableStorageSense.ps1
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-04-22
=================================================================================
#>

# Check if StorageSense key exists. Create if missing.
$key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense"
If (!(Test-Path "$key")){
    New-Item -Path "$key" | Out-Null}

If (!(Test-Path "$key\Parameters")){
    New-Item -Path "$key\Parameters" | Out-Null}

If (!(Test-Path "$key\Parameters\StoragePolicy")){
    New-Item -Path "$key\Parameters\StoragePolicy" | Out-Null}

# Set Storage Sense settings
# Enable Storage Sense
Set-ItemProperty -Path "$key\Parameters\StoragePolicy" -Name "01" -Type DWord -Value 1 -Force

# Set 'Run Storage Sense' to Every Week
Set-ItemProperty -Path "$key\Parameters\StoragePolicy" -Name "2048" -Type DWord -Value 7 -Force

# Enable 'Delete temporary files that my apps aren't using'
Set-ItemProperty -Path "$key\Parameters\StoragePolicy" -Name "04" -Type DWord -Value 1 -Force

# Set 'Delete files in my recycle bin if they have been there for over' to 60 days
Set-ItemProperty -Path "$key\Parameters\StoragePolicy" -Name "08" -Type DWord -Value 1 -Force
Set-ItemProperty -Path "$key\Parameters\StoragePolicy" -Name "256" -Type DWord -Value 60 -Force

# Set 'Delete files in my Downloads folder if they have been there for over' to 60 days
Set-ItemProperty -Path "$key\Parameters\StoragePolicy" -Name "32" -Type DWord -Value 1 -Force
Set-ItemProperty -Path "$key\Parameters\StoragePolicy" -Name "512" -Type DWord -Value 60 -Force

# Set value that Storage Sense has already notified the user
Set-ItemProperty -Path "$key\Parameters\StoragePolicy" -Name "StoragePoliciesNotified" -Type DWord -Value 1 -Force
