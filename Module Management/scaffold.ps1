<#
.SYNOPSIS
    Scaffolds a new PowerShell module project.

.DESCRIPTION
    This script creates the recommended folder structure and sample files
    for a new PowerShell module. It works seamlessly with the companion
    'build.ps1' script to create a compilable and distributable module.

.PARAMETER ModuleName
    The name of the new PowerShell module. This name will be used for the
    main module folder and the manifest file (.psd1).

.EXAMPLE
    PS C:\> .\scaffold.ps1 -ModuleName MyAwesomeModule

    This command creates a new module project named "MyAwesomeModule" in
    the current directory.

.NOTES
    Complete the setup:
    1. Open the project: Open the newly created MyNewModule folder in an IDE like Visual Studio Code.
    2. Start developing: 
        Write your public functions in the 'MyNewModule/YourModule/Public' folder.
        Write your private helper functions in the 'MyNewModule/YourModule/Private' folder.
    3. Test the build: Once you have added or modified your functions, you can test the build process by running the build.ps1 script.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$ModuleName
)

# 1. Define paths
$ProjectRoot = Join-Path -Path $PSScriptRoot -ChildPath $ModuleName
$ModuleSourcePath = Join-Path -Path $ProjectRoot -ChildPath 'YourModule'
$PublicPath = Join-Path -Path $ModuleSourcePath -ChildPath 'Public'
$PrivatePath = Join-Path -Path $ModuleSourcePath -ChildPath 'Private'
$ToolsPath = Join-Path -Path $PSScriptRoot -ChildPath 'tools'

# Check if the project folder already exists to prevent overwriting
if (Test-Path -Path $ProjectRoot) {
    throw "Project directory '$ProjectRoot' already exists. Aborting scaffold."
}

# 2. Create the folder structure
if ($PSCmdlet.ShouldProcess($ProjectRoot, "Create Module Project Folder Structure")) {
    Write-Host "Creating project folder: $ProjectRoot"
    New-Item -Path $ProjectRoot -ItemType Directory | Out-Null
    
    Write-Host "Creating module source folder: $ModuleSourcePath"
    New-Item -Path $ModuleSourcePath -ItemType Directory | Out-Null
    
    Write-Host "Creating Public functions folder: $PublicPath"
    New-Item -Path $PublicPath -ItemType Directory | Out-Null
    
    Write-Host "Creating Private functions folder: $PrivatePath"
    New-Item -Path $PrivatePath -ItemType Directory | Out-Null
    
    Write-Host "Creating tools folder: $ToolsPath"
    New-Item -Path $ToolsPath -ItemType Directory | Out-Null
}

# 3. Create sample function files
$publicFunctionFile = Join-Path -Path $PublicPath -ChildPath "Get-SampleFunction.ps1"
if ($PSCmdlet.ShouldProcess($publicFunctionFile, "Create sample public function file")) {
    Write-Host "Creating sample public function: $publicFunctionFile"
    @"
function Get-SampleFunction {
    [CmdletBinding()]
    param()

    # Public functions are available to users when the module is imported.
    Write-Host "This is a sample public function from $ModuleName."
}
"@ | Set-Content -Path $publicFunctionFile -Encoding UTF8
}

$privateFunctionFile = Join-Path -Path $PrivatePath -ChildPath "Get-SampleHelper.ps1"
if ($PSCmdlet.ShouldProcess($privateFunctionFile, "Create sample private function file")) {
    Write-Host "Creating sample private function: $privateFunctionFile"
    @"
function Get-SampleHelper {
    [CmdletBinding()]
    param()

    # Private functions are for internal use and not exported.
    Write-Host "This is a private helper function."
}
"@ | Set-Content -Path $privateFunctionFile -Encoding UTF8
}

# 4. Create the module manifest (.psd1)
$manifestPath = Join-Path -Path $ModuleSourcePath -ChildPath "$ModuleName.psd1"
if ($PSCmdlet.ShouldProcess($manifestPath, "Create module manifest file")) {
    Write-Host "Creating module manifest: $manifestPath"
    New-ModuleManifest -Path $manifestPath `
        -RootModule "$ModuleName.psm1" `
        -ModuleVersion "0.0.1" `
        -Author "$env:USERNAME" `
        -Description "A reusable PowerShell module for a project named $ModuleName" `
        -Force | Out-Null
}

# 5. Copy the build.ps1 script into the project root
$buildScriptPath = Join-Path -Path $ProjectRoot -ChildPath "build.ps1"
if ($PSCmdlet.ShouldProcess($buildScriptPath, "Create build.ps1 script file")) {
    Write-Host "Copying build.ps1 to project root: $buildScriptPath"
    @"
# Copy the contents of the previous build.ps1 example here
# This script is located in the root of the project
# For example, in the YourModule/ directory

# ... (Paste the entire content of the updated build.ps1 script here) ...
"@ | Set-Content -Path $buildScriptPath -Encoding UTF8
}

Write-Host "Scaffolding of module '$ModuleName' is complete!"
Write-Host "Navigate to '$ProjectRoot' to begin development."

