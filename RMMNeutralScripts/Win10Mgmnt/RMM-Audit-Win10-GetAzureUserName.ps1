RMM-Audit-Win10-GetAzureUserName.ps1

$subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo"

$guids = $subKey.GetSubKeyNames()
foreach($guid in $guids) {
    $guidSubKey = $subKey.OpenSubKey($guid);
    $UserEmail = $guidSubKey.GetValue("UserEmail");
}
write-output $UserEmail
