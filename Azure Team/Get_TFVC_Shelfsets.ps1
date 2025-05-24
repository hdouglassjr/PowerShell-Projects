$organization = "harryteck2"
$project = "MyFirstProject"
$pat = "<your personal access token here>"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$resource = "shelvesets"

$url = "https://dev.azure.com/$($organization)/_apis/tfvc/shelvesets?api-version=7.1"

$response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)}

$response

