$disk = (Get-CimInstance -ClassName win32_DiskDrive | Select -Expand Model).Trim(); if($disk -match 'HPE?.+SAS (2\.5 RI PLP SC SSD|2\.5 MU PLP SC SSD S2|SFF RI SC DS SSD|RI SFF SC DS SSD|12G RI SFF SC DS SSD|RI LFF SCC DS SPL SSD)') {$true} else {$false}
Write-Output "UPSTREAM: Is the HPE SSD Disk: $disk"
