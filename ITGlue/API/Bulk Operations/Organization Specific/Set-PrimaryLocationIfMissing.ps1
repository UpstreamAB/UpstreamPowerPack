# Get all locations.
$data = Get-ITGlueLocations -page_size 1000
# ..as array..
$locations = New-Object System.Collections.ArrayList
# ..and add them to array
foreach($item in $data.data) {
    $locations.Add($item)
}
# Check for more pages. Get the rest of the data if there is.
$page = 1
while($data.meta.'total-pages' -gt $page) {
    $page++
    Get-ITGlueLocations -page_number $page | Select-Object -ExpandProperty data | ForEach-Object {
        $locations.add($_)
    }
}


$locationsToUpdate = @()
$locations | ForEach-Object {
    # Added loop in case if multiple locations
    $_ | ForEach-Object {
        # Check if primary
        if($_.attributes.primary -eq $false) {
            # Prevent duplicates
            if(-not ($locationsToUpdate.attributes.'organization_id' -contains $_.attributes.'organization-id')) {
                $locationsToUpdate += @{
                    type = "locations"
                    attributes = @{
                        id = $_.id
                        primary = 1
                        organization_id = $_.attributes.'organization-id'
                    }
                }
            }
        }
    }
}

Set-ITGlueLocations -data $locationsToUpdate