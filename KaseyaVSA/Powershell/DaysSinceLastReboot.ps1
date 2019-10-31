# Section 3: Uptime
# -----------------------------------------------------------------------------------------------------------------------
function Get-Uptime {
   $os = Get-WmiObject win32_operatingsystem
   $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
   $Display = "UPSTREAM: Machine Compliance Check: Uptime In Days: " + $Uptime.Days
   Write-Output $Display
}

Get-Uptime
