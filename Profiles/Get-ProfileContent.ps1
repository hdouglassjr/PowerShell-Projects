$documents = [Environment]::GetFolderPath('MyDocuments')

$profiles = @(
    'PowerShell\profile.ps1'
    'PowerShell\Microsoft.PowerShell_profile.ps1'
    'PowerShell\Microsoft.VSCode_profile.ps1'
    'WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
)

foreach ($profileFile in $profiles) {

    $path = Join-Path $documents $profileFile

    if (Test-Path -LiteralPath $path) {

        Write-Host "`n$('=' * 70)" -ForegroundColor Cyan
        Write-Host $path -ForegroundColor Cyan
        Write-Host ('=' * 70) -ForegroundColor Cyan

        Get-Content -LiteralPath $path
    }
}