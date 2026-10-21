$viewModel = New-ViewModel 
    -ClassName ServiceViewModel 
    -AutomaticProperties $true 
    -Properties @{
        SearchText = ''
        Services   = $null
    }

$services = Get-Service |
    Sort-Object DisplayName |
    Select-Object `
        Name,
        DisplayName,
        Status

$viewModel.Services = $services
