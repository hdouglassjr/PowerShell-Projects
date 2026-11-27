$moduleName = 'Pester'
$installed = Get-InstalledModule -Name $moduleName
$online = Find-Module -Name $moduleName

[PSCustomObject]@{
    Name = $installed.Name
    Installed = $installed.Version
    LatestOnline = $online.Version
    NeedsUpdate = $online.Version -gt $installed.Version
}
$needsUpdate = $online.Version -gt $installed.Version

if($installed -and $needsUpdate){
    Test-GalleryModuleUpdate $moduleName -NeedUpdateOnly
}
   
