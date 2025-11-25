# Set these as needed
$ModuleName = "MyTool"
$ModuleVersion = "1.0.0"
$Author = "YourName"
$Description = "A cross-platform PowerShell 7+ module that does awesome stuff"
$RepoPath = "$env:USERPROFILE\PowerShellRepo"
$ProjectRoot = "$RepoPath\$ModuleName"

# Create folders
New-Item -Path $ProjectRoot -ItemType Directory -Force
New-Item -Path "$ProjectRoot\Public" -ItemType Directory -Force
New-Item -Path "$ProjectRoot\Private" -ItemType Directory -Force
New-Item -Path "$ProjectRoot\nupkg" -ItemType Directory -Force

@'
function Get-PlatformInfo {
    [CmdletBinding()]
    param()
    [PSCustomObject]@{
        OS      = $PSVersionTable.OS
        Edition = $PSVersionTable.PSEdition
        Version = $PSVersionTable.PSVersion
    }
}
'@ | Out-File -FilePath "$ProjectRoot\Public\Get-PlatformInfo.ps1" -Encoding utf8 -Force

@"
# Auto-import all public/private functions
Get-ChildItem -Path \$PSScriptRoot\Public\*.ps1 -Recurse | ForEach-Object { . \$_ }
Get-ChildItem -Path \$PSScriptRoot\Private\*.ps1 -Recurse | ForEach-Object { . \$_ }
"@ | Out-File -FilePath "$ProjectRoot\$ModuleName.psm1" -Encoding utf8 -Force

New-ModuleManifest -Path "$ProjectRoot\$ModuleName.psd1" `
    -RootModule "$ModuleName.psm1" `
    -ModuleVersion $ModuleVersion `
    -Author $Author `
    -Description $Description `
    -PowerShellVersion "7.0" `
    -FunctionsToExport @('Get-PlatformInfo')

    @"
Import-Module -Name "$ProjectRoot\$ModuleName.psm1" -Force
Get-PlatformInfo | Format-List
"@ | Out-File -FilePath "$ProjectRoot\Dev.ps1" -Encoding utf8 -Force

@"
<?xml version="1.0"?>
<package>
  <metadata>
    <id>MyTool</id>
    <version>1.0.0</version>
    <authors>YourName</authors>
    <description>A PowerShell 7 module for demo purposes</description>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <tags>powershell module</tags>
  </metadata>
  <files>
    <!-- Public and Private function files -->
    <file src="Public\*.ps1" target="MyTool\Public" />
    <file src="Private\*.ps1" target="MyTool\Private" />

    <!-- Module and manifest -->
    <file src="MyTool.psm1" target="MyTool" />
    <file src="MyTool.psd1" target="MyTool" />
  </files>
</package>
"@ | Out-File -FilePath "$ProjectRoot\$ModuleName.nuspec" -Encoding utf8 -Force

nuget pack "$ProjectRoot\$ModuleName.nuspec" -OutputDirectory "$ProjectRoot\nupkg"

New-Item -Path $RepoPath -ItemType Directory -Force
Copy-Item "$ProjectRoot\nupkg\$ModuleName.$ModuleVersion.nupkg" -Destination $RepoPath -Force

# Register only once
if (-not (Get-PSRepository -Name LocalNuget -ErrorAction SilentlyContinue)) {
    Register-PSRepository -Name LocalNuget -SourceLocation $RepoPath -InstallationPolicy Trusted
}

Install-Module -Name $ModuleName -Repository LocalNuget -Force

<#
 # { 
Ready-to-Go Commands for Dev Cycle
Task	                   Command
Run your module	         .\Dev.ps1
Update version	         Use the Update-Version.ps1 script 
Pack module	nuget pack   .\MyTool.nuspec -OutputDirectory .\nupkg
Install module	         Install-Module -Name MyTool -Repository LocalNuget -Force
}
#>