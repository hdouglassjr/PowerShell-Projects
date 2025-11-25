param (
    [Parameter(Mandatory)]
    [string]$NewVersion,

    [string]$ModuleName = "MyTool",
    [string]$Author = "YourName",
    [string]$RepoPath = "$env:USERPROFILE\PowerShellRepo",
    [string]$Description = "A cross-platform PowerShell 7+ module"
)

# Use the directory where this script is located as the project root
$ProjectRoot = $PSScriptRoot

$psd1Path = Join-Path $ProjectRoot "$ModuleName.psd1"
$nuspecPath = Join-Path $ProjectRoot "$ModuleName.nuspec"
$nuPkgOutput = Join-Path $ProjectRoot "nupkg"
$nuPkgFile = "$ModuleName.$NewVersion.nupkg"

# ---------------------------
Write-Host "🔧 Updating version numbers..."

# Update version in .psd1
(Get-Content $psd1Path) -replace 'ModuleVersion\s*=\s*''[\d\.]+''', "ModuleVersion = '$NewVersion'" |
    Set-Content $psd1Path -Encoding utf8

# Update version in .nuspec
(Get-Content $nuspecPath) -replace '<version>[\d\.]+</version>', "<version>$NewVersion</version>" |
    Set-Content $nuspecPath -Encoding utf8

Write-Host "✅ Version updated to $NewVersion"

# ---------------------------
Write-Host "📦 Packing module..."

# Ensure output folder exists
New-Item -Path $nuPkgOutput -ItemType Directory -Force | Out-Null

# Pack using nuget.exe
nuget pack $nuspecPath -OutputDirectory $nuPkgOutput | Out-Null

if (!(Test-Path "$nuPkgOutput\$nuPkgFile")) {
    Write-Error "❌ Failed to pack module."
    exit 1
}

Write-Host "✅ Packed as $nuPkgFile"

# ---------------------------
Write-Host "📁 Copying to local repo..."

# Ensure local repo exists
New-Item -Path $RepoPath -ItemType Directory -Force | Out-Null

# Copy package to repo
Copy-Item "$nuPkgOutput\$nuPkgFile" -Destination $RepoPath -Force

# ---------------------------
Write-Host "📚 Registering PSRepository..."

if (-not (Get-PSRepository -Name LocalNuget -ErrorAction SilentlyContinue)) {
    Register-PSRepository -Name LocalNuget -SourceLocation $RepoPath -InstallationPolicy Trusted
    Write-Host "✅ LocalNuget repository registered"
}

# ---------------------------
Write-Host "📥 Installing module..."

Install-Module -Name $ModuleName -Repository LocalNuget -Force

Write-Host "`n🎉 Build complete. '$ModuleName' v$NewVersion is installed from local repo."
