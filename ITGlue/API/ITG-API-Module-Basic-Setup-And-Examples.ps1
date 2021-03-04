<#
=================================================================================
IT Glue script:     ITG-API-Module-Basic-Setup-And-Examples.ps1
Support type:       Upstream IT Glue Power Pack
Support:            Upstream AB, powerpack@upstream.se
=================================================================================
#>

# -----------------------------------------------------------------
# VARIABLES & OPTIONS

# Your top secret API key generated from Account, Authentication within IT Glue. You have to be IT Glue Administrator in order create this.
$ITGAPI = "Top secret API key"

# Set the region for the IT Glue API endpoint. Non EU IT Glue customers should use "https://api.itglue.com".
$APIEndpoint = "https://api.eu.itglue.com" 

# END OF VARIABLES & OPTIONS
# -----------------------------------------------------------------------------------------------------------------------

# Let's look for the IT Glue Powershell module. Install if missing.
If (Get-Module -ListAvailable -Name "ITGlueAPI") { 
    Import-module ITGlueAPI 
}
Else { 
    Install-Module ITGlueAPI -Force
    Import-Module ITGlueAPI
}

# Let's enable the IT Glue Powershell module based on the API secret and endpoint region above.
Add-ITGlueBaseURI -base_uri $APIEndpoint
Add-ITGlueAPIKey $ITGAPI

# We are now done with the basic IT Glue Powershell module setup.

# We can start exploring the features with a couple of get commands. By design we need to step the query one page with 1000 items at the time.
# Let's create a counter called "$PageCounter" for stepping trough each page number of 1000 items each until reaching the final page.
# You can see this method being repeated in below examples.

# Get all IT Glue Configurations example.
$PageCounter = 0
$AllITGlueConfigs = @()
Do {
        $AllITGlueConfigs += (Get-ITglueconfigurations -page_size 1000 -page_number $PageCounter).Data.Attributes
        $PageCounter++
        Write-Host "UPSTREAM: Retrieved $($AllITGlueConfigs.Count) Configurations"
}While ($AllITGlueConfigs.Count % 1000 -eq 0 -and $AllITGlueConfigs.Count -ne 0)

# Show all Configuration attributes.
Write-Output "UPSTREAM: Show all Configuration attributes:"
$AllITGlueConfigs

# Show Configurataions based on creation date, newest first.
Write-Output "UPSTREAM: Show Configurataions based on creation date, newest first:"
$AllITGlueConfigs | Sort -Property created-at -Descending

# Export all Server type Configurations to CSV example. 

$CSVPath = "c:\temp"
Write-Output "UPSTREAM: Export all Configurations with attribute filter to $CSVPath\Servers.csv:"
$AllITGlueConfigs | Where-Object configuration-type-name -eq Server | Select-Object name,configuration-type-name,organization-id,organization-name | Export-Csv -Path "$CSVPath\Servers.csv" -Encoding UTF8 -NoTypeInformation

# Get all IT Glue Organizationa example
$PageCounter = 0
$AllITGlueOrgs = @()
Do {
        $AllITGlueOrgs += (Get-ITGlueOrganizations -page_size 1000 -page_number $PageCounter).Data.Attributes
        $PageCounter++
        Write-Host "UPSTREAM: Retrieved $($AllITGlueOrgs.Count) Configurations"
}While ($AllITGlueOrgs.Count % 1000 -eq 0 -and $AllITGlueOrgs.Count -ne 0)

# Show all Organization attributes
Write-Output "UPSTREAM: Show all Organization attributes:"
$AllITGlueOrgs

# Show the names of all inactive Orgs.
Write-Output "UPSTREAM: Show the names of all inactive Orgs:"
($AllITGlueOrgs | Where-Object organization-status-name -eq Inactive).Name
