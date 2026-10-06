$moduleName = 'Company.Automation'

$folders = @(
    "$moduleName\Public"
    "$moduleName\Private"
    "$moduleName\Tests"
)
$folders | ForEach-Object {
    New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot $_) -Force
}
New-Item -ItemType File "$moduleName.ps1"
New-Item -ItemType File "$moduleName.psm1"