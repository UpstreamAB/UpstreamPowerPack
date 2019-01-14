[cmdletbinding(DefaultParameterSetName="statusName")]
param(
    [Parameter(ParameterSetName="statusName")]
    [string]$StatusName = "Active",

    [Parameter(ParameterSetName="statusID")]
    [int]$StatusId
)

if($PsCmdlet.ParameterSetName -eq "statusName") {
    $StatusId = (Get-ITGlueOrganizationStatuses -filter_name $StatusName).data.id
    if($StatusId.Count -eq 0 ) {
        Write-Error "No status was wound with the name $StatusName"
        exit
    }
}

# Get all organizations..
$data = Get-ITGlueOrganizations -page_size 1000
# ..as array..
$organizations = New-Object System.Collections.ArrayList
# ..and add them to array
foreach($item in $data.data) {
    $organizations.Add($item)
}
# Check for more pages. Get the rest of the data if there is.
$page = 1
while($data.meta.'total-pages' -gt $page) {
    $page++
    Get-ITGlueOrganizations -page_number $page | Select-Object -ExpandProperty data | ForEach-Object {
        $organizations.add($_)
    }
}

$organizationsToUpdate = @()
$organizations | ForEach-Object {
    # Check if status ID missing
    if(-not $_.attributes.'organization-status-id') {
        # Check for duplicates?
        if(-not ($organizationsToUpdate.attributes.id -contains $_.id)) {
            # Add to update list
            $organizationsToUpdate += @{
                type = "organizations"
                attributes = @{
                    id = $_.id
                    organization_status_id = $StatusId
                }
            }
        }
    }
}

# Update ITGlue
Set-ITGlueOrganizations -data $organizationsToUpdate