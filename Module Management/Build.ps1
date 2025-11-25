<#
.SYNOPSIS
    Compiles a PowerShell module and packages it for NuGet.

.NOTES
    Download nuget.exe: Before running for the first time, manually create a tools folder in your project root and place the nuget.exe file inside. Or, rely on the script to download it automatically.

.DESCRIPTION
    This script automates the full build and NuGet packaging process for a
    PowerShell module. It performs the following steps:
    1.  Sets up the build environment.
    2.  Installs or updates nuget.exe.
    3.  Creates a clean output directory.
    4.  Consolidates individual function files into a monolithic .psm1 file.
    5.  Ensures the module manifest (.psd1) is up-to-date.
    6.  Creates a NuGet package (.nupkg) using nuget.exe.
    7.  Optionally publishes the package to a NuGet feed.

.PARAMETER Clean
    Removes the build output directory before performing the build.

.PARAMETER Publish
    Publishes the generated NuGet package to the specified NuGet feed.

.PARAMETER NuGetApiKey
    The API key for the NuGet feed, required when -Publish is used.

.EXAMPLE
    ./build.ps1
    Runs the build process for the current module.

.EXAMPLE
    .\build.ps1 -Clean
    Removes the output directory before performing the build.

    .EXAMPLE
    .\build.ps1 -Publish -NuGetApiKey "your-api-key"
    Publishes the generated NuGet package to the feed using the provided API key.
#>
[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Cleans the build output directory before starting.")]
    [Switch]$Clean,

    [Parameter(HelpMessage = "Publishes the NuGet package after creation.")]
    [Switch]$Publish,

    [Parameter(HelpMessage = "The API key for publishing to the NuGet feed. Mandatory if -Publish is used.")]
    [string]$NuGetApiKey
)

# 1. Define paths and variables
$ModulePath = "$PSScriptRoot\YourModule"
$ModuleName = (Get-Item -Path $ModulePath).Name
$BuildPath = "$PSScriptRoot\build"
$ReleasePath = "$BuildPath\release"
$CompiledModulePath = "$ReleasePath\$ModuleName\$ModuleName.psm1"
$ModuleManifestPath = "$ModulePath\$ModuleName.psd1"

# NuGet settings
$NuGetExePath = "$PSScriptRoot\tools\nuget.exe"
$NuGetFeedUrl = "https://www.nuget.org/" # Or your private feed, e.g., "https://pkgs.dev.azure.com/..."

Write-Host "--- Starting Module Build for $ModuleName ---"

# 2. Clean the output directory if -Clean switch is used
if ($Clean) {
    Write-Host "Cleaning build directory: $BuildPath"
    if (Test-Path -Path $BuildPath) {
        Remove-Item -Path $BuildPath -Recurse -Force
    }
}

# Create the release output directory
if (-not (Test-Path -Path $ReleasePath)) {
    New-Item -Path $ReleasePath -ItemType Directory -Force | Out-Null
}

# 3. Ensure nuget.exe is available
if (-not (Test-Path -Path $NuGetExePath)) {
    Write-Host "Downloading nuget.exe..."
    New-Item -Path "$PSScriptRoot\tools" -ItemType Directory -Force | Out-Null
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $NuGetExePath
}

# 4. Consolidate functions into a single .psm1 file
Write-Host "Consolidating individual function files into $CompiledModulePath"
$publicFunctions = Get-ChildItem -Path "$ModulePath\Public" -Filter "*.ps1"
$privateFunctions = Get-ChildItem -Path "$ModulePath\Private" -Filter "*.ps1"

# Combine public and private functions into one file in the release path
$functionsToCombine = $publicFunctions + $privateFunctions
foreach ($file in $functionsToCombine) {
    Get-Content -Path $file.FullName | Out-File -FilePath $CompiledModulePath -Append -Encoding UTF8
}

# Ensure the final compiled psm1 file has a command to export public functions.
$publicFunctionNames = $publicFunctions.BaseName | ForEach-Object { "'$_'" }
$exportFunctionsCommand = "Export-ModuleMember -Function $($publicFunctionNames -join ', ')"
$exportFunctionsCommand | Out-File -FilePath $CompiledModulePath -Append -Encoding UTF8

# 5. Update and copy the module manifest (.psd1)
Write-Host "Updating and copying module manifest file."
# Get existing manifest data
$manifestData = Import-PowerShellDataFile -Path $ModuleManifestPath

# Get the module version from the manifest
$ModuleVersion = $manifestData.ModuleVersion

# Update the RootModule entry to point to the newly compiled .psm1
$manifestData.RootModule = "$ModuleName.psm1"

# Write the updated manifest to the release directory
$manifestData | New-ModuleManifest -Path "$ReleasePath\$ModuleName\$ModuleName.psd1" -Force

# 6. Create the NuGet package
Write-Host "Creating NuGet package..."
$packArgs = @(
    "pack",
    "$ReleasePath\$ModuleName\$ModuleName.psd1",
    "-OutputDirectory", $ReleasePath,
    "-NoPackageAnalysis"
)

# Execute nuget.exe to create the package
& $NuGetExePath $packArgs

Write-Host "NuGet package created: $ReleasePath\$ModuleName.$ModuleVersion.nupkg"

# 7. Publish to NuGet feed if requested
if ($Publish) {
    if (-not $NuGetApiKey) {
        Write-Error "A NuGet API key is required to publish. Please provide it with the -NuGetApiKey parameter."
        return
    }
    
    Write-Host "Publishing NuGet package to $NuGetFeedUrl"
    $pushArgs = @(
        "push",
        "$ReleasePath\$ModuleName.$ModuleVersion.nupkg",
        "-Source", $NuGetFeedUrl,
        "-ApiKey", $NuGetApiKey,
        "-SkipDuplicate" # Skips if the package version already exists
    )
    
    & $NuGetExePath $pushArgs
}

Write-Host "--- Build Process Complete ---"
