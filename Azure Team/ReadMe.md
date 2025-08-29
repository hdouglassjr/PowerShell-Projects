## Azure DevOps Services REST API
### Version 7.1

- [Controller to handle all Rest Calls for Changeset Changes](https://learn.microsoft.com/en-us/rest/api/azure/devops/tfvc/changesets?view=azure-devops-rest-7.1)
- [Getting Labels](https://learn.microsoft.com/en-us/rest/api/azure/devops/tfvc/labels?view=azure-devops-rest-7.1)
- [Get and List Shelvesets](https://learn.microsoft.com/en-us/rest/api/azure/devops/tfvc/shelvesets?view=azure-devops-rest-7.1)

### Personal Access Tokens (PATs)
In order for the requests in this API to be executed, they need to be authorized with Azure AD access token.

#### PowerShell Examples
##### Get Azure DevOps PATs

```powershell
$auth = "Bearer <Azure AD token>"
$azureDevOpsApiVersion = "{latest API version}"
$headers = @{
    'Authorization' = $auth
}

Invoke-RestMethod -H $headers "https://vssps.dev.azure.com/{organization}/_apis/Tokens/Pats?api-version=$azureDevOpsApiVersion"
```
#### Get Changesets
```powershell
$organization = "harryteck2"
$project = "MyFirstProject"
$pat = "<your personal access token here>"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$resource = "changesets"

$url = "https://dev.azure.com/$organization/$project/_apis/tfvc/$($resource)?api-version=7.0"

$response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)}

$response.value | Get-Member

$response.value | ForEach-Object {
    Write-Output "Changeset ID: $($_.changesetId)"
    Write-Output "Author: $($_.author.DisplayName)"
    Write-Output "Creation Date: $($_.createdDate)"
    Write-Output "Checked In By: $($_.checkedInBy.DisplayName)"
    Write-Output "Comment: $($_.comment)"
    Write-Output "--------------------------------"
}


```

#### Get Shelvesets
```powershell
$organization = "harryteck2"
$project = "MyFirstProject"
$pat = "<your personal access token here>"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$resource = "shelvesets"

$url = "https://dev.azure.com/$($organization)/_apis/tfvc/shelvesets?api-version=7.1"

$response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)}

$response

```