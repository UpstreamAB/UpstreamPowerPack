[cmdletbinding()]
param(
    [Parameter(Mandatory=$True)]
    [int64]$ID,
    
    [Parameter(Mandatory=$True)]
    [String]$SaveLocation
)

# Simple error handling
$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Inquire"

$assetData = @()
(Get-ITGlueFlexibleAssetFields -flexible_asset_type_id $ID).data.attributes | ForEach-Object {
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


$orgAsset = (Get-ITGlueFlexibleAssetTypes -id $ID).data.attributes
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

(($data | ConvertTo-Json -Depth 100) -split '\r\n' | ForEach-Object {
    $line = $_
    if ($_ -match '^ +') {
        $len  = $Matches[0].Length / 4
        $line = ' ' * $len + $line.TrimStart()
    }
    $line | Out-File -FilePath "$($SaveLocation)\JSON.txt" -Append
}) -join "`r`n" 

# Restore ErrorActionPreference
$ErrorActionPreference = $OldErrorActionPreference