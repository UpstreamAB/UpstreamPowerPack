param(
    [Parameter(ValueFromPipeline=$true)]
    $name = $env:COMPUTERNAME
)
$resp = (Get-ITGlueConfigurations -filter_name $name).data.id
if(!$resp) {
    "null"
} else if($resp.count > 1) {
    "More than 1 found"
} else {
    $resp
}