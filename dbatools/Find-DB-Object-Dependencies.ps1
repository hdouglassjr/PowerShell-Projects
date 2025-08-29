param(
    [string]$SqlInstance,
    [string]$Database,
    [string]$ColumnName,
    [string]$TableName = "",
    [string]$SchemaName = "dbo"
)

# Import dbatools if not already loaded
Import-Module dbatools -ErrorAction Stop

# Get all relevant programmable objects
$objects = Get-DbaDbObject -SqlInstance $SqlInstance -Database $Database -Type 'StoredProcedure', 'View'

# Prepare the search text
$searchPattern = if ($TableName) {
    "$SchemaName.$TableName.$ColumnName"  # Fully qualified
} else {
    $ColumnName
}

# Find where the column is referenced
$matches = $objects | Where-Object {
    $_.Definition -match [regex]::Escape($searchPattern)
} | Select-Object Name, Type, Schema, Definition

# Output the results
if ($matches) {
    Write-Host "The column '$searchPattern' is referenced in the following objects:`n" -ForegroundColor Cyan
    $matches | Format-Table Name, Type, Schema -AutoSize
} else {
    Write-Host "No references found for column '$searchPattern' in stored procedures or views." -ForegroundColor Yellow
}
