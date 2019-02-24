$DiskHealth = Get-PhysicalDIsk |  Select-Object HealthStatus
Write-Output $DiskHealth
