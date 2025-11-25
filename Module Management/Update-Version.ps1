# Usage:.\Update-Version.ps1 -NewVersion "1.1.0"


param (
    [Parameter(Mandatory)]
    [string]$NewVersion,

    [string]$ProjectRoot = "$PWD\MyTool",
    [string]$ModuleName = "MyTool"
)

$psd1Path = Join-Path $ProjectRoot "$ModuleName.psd1"
$nuspecPath = Join-Path $ProjectRoot "$ModuleName.nuspec"

# 1. Update version in .psd1
(Get-Content $psd1Path) -replace 'ModuleVersion\s*=\s*''[\d\.]+''', "ModuleVersion = '$NewVersion'" |
    Set-Content $psd1Path -Encoding utf8

Write-Host "✅ Updated version in .psd1 to $NewVersion"

# 2. Update version in .nuspec
(Get-Content $nuspecPath) -replace '<version>[\d\.]+</version>', "<version>$NewVersion</version>" |
    Set-Content $nuspecPath -Encoding utf8

Write-Host "✅ Updated version in .nuspec to $NewVersion"
