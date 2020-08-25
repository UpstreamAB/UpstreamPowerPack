<#
=================================================================================
Filename:           RMM-SysMgmt-Win10-VerifyAndRepairPrintToPDF
Support type:       Upstream Power Pack
Support:            Upstream AB, powerpack@upstream.se Last updated 2020-04-22
=================================================================================
#>

If((Get-Printer -Name 'Microsoft Print to PDF')){
	Write-Output "UPSTREAM: Verify: Microsoft Print to PDF: Present: True"}

Else{
	Write-Output "UPSTREAM: Verify: Microsoft Print to PDF: Present: False"
	Write-Output "UPSTREAM: Verify: Microsoft Print to PDF: Recreating printer queue"
	Enable-WindowsOptionalFeature -online -FeatureName Printing-PrintToPDFServices-Features -All >Null}
