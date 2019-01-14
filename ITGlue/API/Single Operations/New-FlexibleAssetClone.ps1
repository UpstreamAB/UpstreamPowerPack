[cmdletbinding()]
param(
    [Parameter(Mandatory=$True)]
    [int]$ID
)

$assetData = @()
(Get-ITGlueFlexibleAssetFields -flexible_asset_type_id $ID -ErrorAction Stop).data.attributes | ForEach-Object {
    $assetDataTemp = [ordered]@{}
    $_.PSObject.Properties | ForEach-Object {
        if($_.Name.GetType().Name -eq "String" -and $_.Name.Contains("-")) {
            $name = $_.Name.Replace("-","_")
        } else {
            $name = $_.Name
        }


        $assetDataTemp.Add($name, $_.Value)
    }

    $assetDataTemp.Remove("created_at")
    $assetDataTemp.Remove("updated_at")
    $assetDataTemp.Remove("flexible_asset_type_id")
    $assetDataTemp.Remove("decimals")

    $tempBody = @{
        type = 'flexible_asset_fields'
        attributes = $assetDataTemp
    }

    $assetData += $tempBody
}


$orgAsset = (Get-ITGlueFlexibleAssetTypes -id $ID -ErrorAction Stop).data.attributes
$data = [ordered]@{
    type = 'flexible_asset_types'
    attributes = @{
        name = "$($orgAsset.name) clone"
        description = $orgAsset.description
        icon = $orgAsset.icon
        enabled = $orgAsset.enabled
    }
    relationships = @{
        flexible_asset_fields = @{
            data = @(
                $assetData
            )
        }
    }
}

New-ITGlueFlexibleAssetTypes -data $data