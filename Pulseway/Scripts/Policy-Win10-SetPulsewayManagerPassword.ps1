<#
=================================================================================
Pulseway script:    Monitor: Win10: Set Pulseway Manager Password
Support type:       Upstream Pulseway Power Free
Support:            Upstream AB, powerpack@upstream.se
Lastest version:    2020-10-28

.DESCRIPTION
This script will add a password to Pulseway Manager locally on the computers and disable the users ability to do any changes
that may prevent or disrupt you services. Use a template computer to generate a hash by entering a password in Pulseway Manager.
Extract the values from the following registry keys:
"KLM:\SOFTWARE\MMSOFT Design\PC Monitor\PreventChangesPassword"
"HKLM:\SOFTWARE\MMSOFT Design\PC Monitor\PreventChangesPasswordCtrl"
#>

# --------------------------------------------------------------------------------------------------------------------------------
# VARIABLES & OPTIONS

# Enter the generated password and control hash
# The default password in this example is: UpstreamPulsewayPowerPack
$PreventChangesPassword = "tJ8aoj4Spp256q9SvCUfpkoPPaevpgtcrtRrCFw3U8fedC7VzTZXCoTUGxYe1eAbubSsDxs1ziYAY+bnHo+y5ov1y2FCs7D8Te5pmngEeTsMOCeIpvWsyeK0wrn5DhGvbrgHS2w2ub2c6SxRnJdDxw=="
$PreventChangesPasswordCtrl = "51-AB-3A-63-07-25-72-35-70-41-BC-56-E1-76-03-8F"

# END OF VARIABLES & OPTIONS
# -----------------------------------------------------------------------------------------------------------------------

# Enable Pulseway Manager password protection
Set-ItemProperty -Path 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor' -Name PreventChanges -Value 1 -Force

# The hashed password
Set-ItemProperty -Path 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor' -Name PreventChangesPassword -Value "$PreventChangesPassword " -Force

The password hash control
Set-ItemProperty -Path 'HKLM:\SOFTWARE\MMSOFT Design\PC Monitor' -Name PreventChangesPasswordCtrl -Value "$PreventChangesPasswordCtrl" -Force

Write-Output "UPSTREAM: Basic: Policy: Pulseway Manager password protection enabled."