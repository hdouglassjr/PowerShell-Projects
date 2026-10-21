New-UiInput -Label 'SQL server' -Variable 'sqlServer' -Default '(localdb)\MSSQLLocalDB'
New-UiButton -Text 'Connect' -NoOutput -Capture 'conn' -Action {
    $conn = [System.Data.SqlClient.SqlConnection]::new("Server=$sqlServer;Database=AdventureWorksDW2025;Integrated Security=True")
    $conn.Open()
    Write-Status "Connected to $sqlServer"
}
New-UiButton -Text 'Count servers' -EnabledWhen 'conn' -Action {
    $query = $conn.CreateCommand()
    $query.CommandText = 'SELECT TOP (10) 
      [FirstName]
      ,[LastName]
      ,[EmailAddress]
      ,[DepartmentName]
      ,[StartDate]
      ,[EndDate]
      ,[Status]
  FROM [AdventureWorksDW2025].[dbo].[DimEmployee]'

    Write-Host "$($query.ExecuteScalar()) servers in Inventory"
}
New-UiStatusBar -DefaultText 'Not connected'