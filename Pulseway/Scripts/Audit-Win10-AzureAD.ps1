<#
=================================================================================
Pulseway script:    Audit: Win10: AzureAD
Support type:       Upstream Pulseway Power Free
Support:            Upstream AB, powerpack@upstream.se
Lastest version:    2020-10-28

Required variable inputs:
None

Required variable outputs:
Name: "OutputAzureADTenanName"
Default Value: "Not Detected"
Associated Custom Field: "Azure AD: Tenant Name"

Name: "OutputAzureADUsername"
Default Value: "Not Detected"
Associated Custom Field: "Azure AD: User Name"
=================================================================================
#>

# Azure AD Tenant Name
Try{
    $SubKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/TenantInfo" -ErrorAction Stop
    $Guids = $subKey.GetSubKeyNames()
    ForEach($Guid in $Guids){
        $GuidSubKey = $SubKey.OpenSubKey($Guid)
        $OutputAzureADTenanName = $GuidSubKey.GetValue("DisplayName")}
        Write-Output "UPSTREAM: Extended Audit: AzureAD: Tenant Name: $OutputAzureADTenanName"
        Start-Process -FilePath "$env:PWY_HOME\CLI.exe" -ArgumentList ("setVariable OutputAzureADTenanName ""$OutputAzureADTenanName""") -Wait}

Catch{
    Write-Output "UPSTREAM: Extended Audit: AzureAD: Tenant Name: Not Detected"}

# Azure AD User Name
Try{
    $SubKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo" -ErrorAction Stop
    $Guids = $SubKey.GetSubKeyNames()
    ForEach($Guid in $Guids) {
        $GuidSubKey = $SubKey.OpenSubKey($Guid)
        $OutputAzureADUserName = $GuidSubKey.GetValue("UserEmail")}
        Write-Output "UPSTREAM: Extended Audit: AzureAD: User Name: $OutputAzureADUserName"
        Start-Process -FilePath "$env:PWY_HOME\CLI.exe" -ArgumentList ("setVariable OutputAzureADUserName $OutputAzureADUserName") -Wait}

Catch{
    Write-Output "UPSTREAM: Extended Audit: AzureAD: User Name: Not Detected"}
