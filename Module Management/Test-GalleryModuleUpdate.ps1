function Test-GalleryModuleUpdate
{
    param
    (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [version]
        $Version,

        [switch]
        $NeedUpdateOnly

    )
    
    process
    {
        [version]$latest = (Find-Module -Name $Name -Repository PSGallery -ErrorAction Stop).Version
        $needsupdate = $Latest -gt $Version

        if ($needsupdate -or (!$NeedUpdateOnly.IsPresent))
        {
            [PSCustomObject]@{
                ModuleName = $Name
                CurrentVersion = $Version
                LatestVersion = $Latest
                NeedsUpdate = $needsupdate
            }
        }
    }
}

Get-InstalledModule | Where-Object Repository -eq PSGallery | 
  Test-GalleryModuleUpdate -NeedUpdateOnly