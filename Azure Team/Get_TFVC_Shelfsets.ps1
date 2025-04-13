$organization = "harryteck2"
$project = "MyFirstProject"
$pat = "5sd9PEhxM3kIMBAwaFSAYvDJ3YPy3Fwgy5hK23imsqxuW3w85IUMJQQJ99BCACAAAAAy6nhCAAASAZDO3uAf"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$resource = "shelvesets"

$url = "https://dev.azure.com/$($organization)/_apis/tfvc/shelvesets?api-version=7.1"

$response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)}

$response

