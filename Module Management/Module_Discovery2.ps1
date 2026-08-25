$moduleName = 'Plaster'
$installed = Get-InstalledModule -Name $moduleName
$online = Find-Module -Name $moduleName

[PSCustomObject]@{
    Name = $installed.Name
    Installed = $installed.Version
    LatestOnline = $online.Version
    NeedsUpdate = $online.Version -gt $installed.Version
}

Get-InstalledModule |
    Where-Object Repository -eq 'PSGallery' |
    Test-GalleryModuleUpdate -NeedUpdateOnly
