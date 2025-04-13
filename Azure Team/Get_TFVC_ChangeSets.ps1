$organization = "harryteck2"
$project = "MyFirstProject"
$pat = "5sd9PEhxM3kIMBAwaFSAYvDJ3YPy3Fwgy5hK23imsqxuW3w85IUMJQQJ99BCACAAAAAy6nhCAAASAZDO3uAf"
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