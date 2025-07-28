
<#
    PowerShellGet is for 5.1
    Also, NuGet provider is required for PowerShellGet to work.

#>
if ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -eq 1) {
    If (-not (Get-InstalledModule -Name PowerShellGet)) {
        Install-Module -Name PowerShellGet -Scope CurrentUser -Force
    }
    If (-not (Get-PackageProvider -Name NuGet)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5 -Scope CurrentUser -Force
    }
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}
Get-module -name nuget -ListAvailable | Select-Object -Property Name, Version, Path, Description | Format-Table -AutoSize