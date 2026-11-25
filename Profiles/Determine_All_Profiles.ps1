
$documents = [Environment]::GetFolderPath('MyDocuments')

$folders = @(
    "$HOME\Documents\PowerShell"
    "$HOME\Documents\WindowsPowerShell"
    "$HOME\OneDrive\Documents\PowerShell"
    "$HOME\OneDrive\Documents\WindowsPowerShell"
)

$results = foreach ($folder in $folders) {

    if (Test-Path -LiteralPath $folder) {

        Get-ChildItem -LiteralPath $folder -Filter '*.ps1' -File |
            ForEach-Object {

                [PSCustomObject]@{
                    FileName      = $_.Name
                    Directory     = $_.DirectoryName
                    LastModified  = $_.LastWriteTime
                    Size          = $_.Length
                    ActiveFolder  = $folder -in @(
                        (Join-Path $documents 'PowerShell')
                        (Join-Path $documents 'WindowsPowerShell')
                    )
                }
            }
    }
}

$results |
    Sort-Object FileName, Directory |
    Format-Table -AutoSize
