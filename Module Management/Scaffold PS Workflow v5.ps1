# Variables
$ModuleName = "MyTool"
$ModuleVersion = "1.0.0"
$Author = "YourName"
$RepoPath = "$env:USERPROFILE\source\PowerShellRepo"
$ProjectRoot = "$PWD\$ModuleName"
$ModulePath = "$ProjectRoot\$ModuleName.psm1"
$ManifestPath = "$ProjectRoot\$ModuleName.psd1"
$NuspecPath = "$ProjectRoot\$ModuleName.nuspec"
$NuPkgOutput = "$ProjectRoot\nupkg"

# 1. Create project structure
New-Item -Path $ProjectRoot -ItemType Directory -Force
New-Item -Path "$ProjectRoot\Public" -ItemType Directory -Force
New-Item -Path "$ProjectRoot\Private" -ItemType Directory -Force
New-Item -Path "$ProjectRoot\nupkg" -ItemType Directory -Force

# 2. Sample function (public)
@'
function Get-Weather {
    [CmdletBinding()]
    param([string]$City)
    "Fetching weather for $City..."
}
'@ | Out-File -FilePath "$ProjectRoot\Public\Get-Weather.ps1" -Encoding utf8 -Force

# 3. Create the .psm1 loader
@"
# Auto-import all public/private functions
Get-ChildItem -Path \$PSScriptRoot\Public\*.ps1 | ForEach-Object { . \$_ }
Get-ChildItem -Path \$PSScriptRoot\Private\*.ps1 | ForEach-Object { . \$_ }
"@ | Out-File -FilePath $ModulePath -Encoding utf8 -Force

# 4. Create the module manifest
New-ModuleManifest -Path $ManifestPath `
    -RootModule "$ModuleName.psm1" `
    -ModuleVersion $ModuleVersion `
    -Author $Author `
    -Description "A sample tool that fetches weather data" `
    -FunctionsToExport @('Get-Weather') `
    -PowerShellVersion '5.1'

# 5. Create a test/dev harness
@"
Import-Module -Name "$ProjectRoot\$ModuleName.psm1" -Force
Get-Weather -City 'Tokyo'
"@ | Out-File -FilePath "$ProjectRoot\Dev.ps1" -Encoding utf8 -Force

# 6. Create NuSpec file
@"
<?xml version="1.0"?>
<package >
  <metadata>
    <id>$ModuleName</id>
    <version>$ModuleVersion</version>
    <authors>$Author</authors>
    <description>A sample PowerShell module for demonstration</description>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
  </metadata>
  <files>
    <file src="Public\*.ps1" target="content\$ModuleName\Public" />
    <file src="Private\*.ps1" target="content\$ModuleName\Private" />
    <file src="$ModuleName.psm1" target="content\$ModuleName" />
    <file src="$ModuleName.psd1" target="content\$ModuleName" />
  </files>
</package>
"@ | Out-File -FilePath $NuspecPath -Encoding utf8 -Force

# 7. Create local NuGet repository folder
New-Item -Path $RepoPath -ItemType Directory -Force

# 8. Pack the module as a NuGet package
nuget pack $NuspecPath -OutputDirectory $NuPkgOutput | Out-Null

# 9. Copy the .nupkg to your local repo
Copy-Item "$NuPkgOutput\$ModuleName.$ModuleVersion.nupkg" -Destination $RepoPath -Force

# 10. Register the local NuGet repo with PowerShell
$existing = Get-PSRepository -Name LocalNuget -ErrorAction SilentlyContinue
if (-not $existing) {
    Register-PSRepository -Name LocalNuget -SourceLocation $RepoPath -InstallationPolicy Trusted
}

# 11. Install the module from the local NuGet repository
Install-Module -Name $ModuleName -Repository LocalNuget -Force

Write-Host "✅ Module '$ModuleName' v$ModuleVersion is built, packaged, and installed from local repo."
