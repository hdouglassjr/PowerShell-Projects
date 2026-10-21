<#
.SYNOPSIS
    Scaffolds a new PowerShell module project with standard folders, files, and tests.
.DESCRIPTION
    Creates a complete module structure including:
    - Standard module folders (Public, Private, Tests, Private/Tests)
    - Module manifest
    - Pester test skeleton
    - .gitignore, .editorconfig, README
    - GitHub Actions CI/CD workflow
    - ScriptAnalyzer settings
.EXAMPLE
    .\New-ModuleProject.ps1 -ModuleName MyUtilities
.EXAMPLE
    .\New-ModuleProject.ps1 -ModuleName MyTools -Author "Jane Doe" -License Apache-2.0
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ModuleName,

    [string]$Author = $env:USERNAME,

    [string]$Company = '',

    [string]$Description = "A PowerShell module",

    [string]$LicenseUri = 'https://opensource.org/license/MIT',

    [string]$ProjectUri = '',

    [ValidateSet('MIT', 'Apache-2.0', 'GPL-3.0', 'Proprietary')]
    [string]$License = 'MIT'
)

# --- Helpers ---
function Write-Step {
    param([string]$Message)
    Write-Host "`n== $Message ==" -ForegroundColor Cyan
}

# --- Validate module name ---
if ($ModuleName -notmatch '^[A-Z][a-zA-Z0-9]*$') {
    throw "Module name must start with an uppercase letter and contain only alphanumeric characters (e.g. MyModule). Got: $ModuleName"
}

$moduleFolder = Join-Path $PWD $ModuleName
if (Test-Path $moduleFolder) {
    throw "Directory already exists: $moduleFolder"
}

# --- Step 1: Create folder structure ---
Write-Step "Creating folder structure"

$folders = @(
    'Public',
    'Private',
    'Tests',
    'Private\Tests',
    'docs'
)

foreach ($folder in $folders) {
    $path = Join-Path $moduleFolder $folder
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Write-Host "  + $path"
}

# --- Step 2: Create module manifest ---
Write-Step "Creating module manifest"

$manifestPath = Join-Path $moduleFolder "${ModuleName}.psd1"
#$projectUriValue = if ($ProjectUri) { $ProjectUri } else { $null }
$companyNameValue = if ($Company) { $Company } else { 'Unknown' }

New-ModuleManifest "$manifestPath" `
    -RootModule "${ModuleName}.psm1" `
    -ModuleVersion '1.0.0' `
    -Guid (New-Guid).Guid `
    -Author $Author `
    -CompanyName $companyNameValue `
    -Description $Description `
    -PowerShellVersion '5.1' `
    -CompatiblePSEditions 'Core','Desktop' `
    -FunctionsToExport '*' `
    -Copyright "(c) $Author. Licensed under $License" 

# --- Step 3: Create module loader (.psm1) ---
Write-Step "Creating module loader"

$psm1Path = Join-Path $moduleFolder "${ModuleName}.psm1"

@"
# Import public functions
`$publicFunctions = Get-ChildItem -Path '$PWD\Public\*.ps1' -Recurse

foreach (`$function in `$publicFunctions) {
    try {
        . `$function.FullName
    }
    catch {
        Write-Error -Message "Failed to import function (`$function.FullName)"
    }
}

# Export all public functions
Export-ModuleMember -Function `$publicFunctions.BaseName
"@ -replace '\\\$PWD', $moduleFolder |
    Set-Content -Path $psm1Path -Encoding UTF8

Write-Host "  + $psm1Path"

# --- Step 4: Create sample public function ---
Write-Step "Creating sample public function"

$sampleFunctionPath = Join-Path $moduleFolder "Public\Get-${ModuleName}Info.ps1"

@"
<#
.SYNOPSIS
    Returns information about the module.
.DESCRIPTION
    Returns basic metadata about this module.
.EXAMPLE
    Get-${ModuleName}Info
.PARAMETER AsJson
    Return output as JSON string.
#>
[CmdletBinding()]
[OutputType([PSCustomObject])]
param(
    [switch]`$AsJson = `$false
)

begin {
    `$info = [PSCustomObject]@{
        ModuleName    = '${ModuleName}'
        Version       = '${manifest.ModuleVersion}'
        PowerShell    = $PSVersionTable.PSVersion.ToString
        Platform      = $PSVersionTable.PSVersion.Platform
    }
}

process {
    if (`$AsJson) {
        `$info | ConvertTo-Json -Depth 3
    }
    else {
        `$info
    }
}
"@ | Set-Content -Path $sampleFunctionPath -Encoding UTF8

Write-Host "  + $sampleFunctionPath"

# --- Step 5: Create Pester test file ---
Write-Step "Creating Pester tests"

$testPath = Join-Path $moduleFolder "Tests\${ModuleName}.Tests.ps1"

@"
#requires -Modules Pester

`$here = Split-Path -Parent \$MyInvocation.MyCommand.Path
`$sut = (Split-Path -Leaf \$MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

# Import the module
Import-Module '${moduleFolder}\${ModuleName}.psm1' -Force

Describe '${ModuleName} module' {
    Context 'Get-${ModuleName}Info' {
        It 'returns a PSCustomObject' {
            `$result = Get-${ModuleName}Info
            `$result | Should -BeOfType PSCustomObject
        }

        It 'contains the module name' {
            `$result = Get-${ModuleName}Info
            `$result.ModuleName | Should -Be '${ModuleName}'
        }

        It 'returns JSON when -AsJson is used' {
            `$result = Get-${ModuleName}Info -AsJson
            `$result | Should -BeOfType string
            (`$result | ConvertFrom-Json).ModuleName | Should -Be '${ModuleName}'
        }
    }
}
"@ | Set-Content -Path $testPath -Encoding UTF8

Write-Host "  + $testPath"

# --- Step 6: Create .gitignore ---
Write-Step "Creating .gitignore"

@"
## PowerShell
*.psd1
*.psm1
*.ps1
*.ps1xml
*.pssc
*.cdxml
obj/
bin/
*.nupkg
*.psm1.bak
*.psd1.bak

## IDE
.vscode/
.idea/
*.suo
*.user

## OS
.DS_Store
Thumbs.db

## Pester
coverage.xml
coverage.cobertura.xml

## Modules
\$env:USERPROFILE/OneDrive/
"@ | Set-Content -Path (Join-Path $moduleFolder '.gitignore') -Encoding UTF8

Write-Host "  + .gitignore"

# --- Step 7: Create .editorconfig ---
Write-Step "Creating .editorconfig"

@"
root = true

[*.ps1]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.psd1]
indent_style = space
indent_size = 4
"@ | Set-Content -Path (Join-Path $moduleFolder '.editorconfig') -Encoding UTF8

Write-Host "  + .editorconfig"

# --- Step 8: Create README ---
Write-Step "Creating README"

@"
# ${ModuleName}

${Description}

## Installation

\`\`\`powershell
Install-Module -Name ${ModuleName} -Scope CurrentUser
\`\`\`

## Usage

\`\`\`powershell
Get-${ModuleName}Info
\`\`\`

## Development

### Running tests

\`\`\`powershell
cd ${ModuleName}
Invoke-Pester -Path ./Tests -Output Detailed
\`\`\`

## License

Licensed under the [${License} License](LICENSE).
"@ | Set-Content -Path (Join-Path $moduleFolder 'README.md') -Encoding UTF8

Write-Host "  + README.md"

# --- Step 9: Create LICENSE ---
Write-Step "Creating LICENSE"

$licenseText = switch ($License) {
    'MIT' {
        @"
MIT License

Copyright (c) ${Author}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@
    }
    'Apache-2.0' {
        @"
Apache License
Version 2.0, January 2004
http://www.apache.org/licenses/

Copyright (c) ${Author}

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"@
    }
    'GPL-3.0' {
        @"
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (c) ${Author}

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"@
    }
    'Proprietary' {
        @"
Copyright (c) ${Author}. All rights reserved.
"@
    }
}

$licensePath = Join-Path $moduleFolder 'LICENSE'
$licenseText | Set-Content -Path $licensePath -Encoding UTF8
Write-Host "  + LICENSE"

# --- Step 10: Create GitHub Actions CI/CD workflow ---
Write-Step "Creating GitHub Actions workflow"

$githubPath = Join-Path $moduleFolder '.github/workflows'
New-Item -ItemType Directory -Path $githubPath -Force | Out-Null

$workflowPath = Join-Path $githubPath 'ci.yml'

@"
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: \${ matrix.os }
    strategy:
      fail-fast: false
      matrix:
        os: [windows-latest, ubuntu-latest, macos-latest]

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Test with Pester
        shell: pwsh
        run: |
          Install-Module -Name Pester -Force -Scope CurrentUser -SkipPublisherCheck
          Import-Module -Name Pester
          Invoke-Pester -Path ./Tests -Output Detailed
"@ | Set-Content -Path $workflowPath -Encoding UTF8

Write-Host "  + .github/workflows/ci.yml"

# --- Step 11: Create PSScriptAnalyzer settings ---
Write-Step "Creating PSScriptAnalyzer settings"

$settingsPath = Join-Path $moduleFolder 'PSScriptAnalyzerSettings.psd1'

@"
@{
    Severity = @('Error', 'Warning')
    IncludeRules = @('PSUseConsistentIndentation', 'PSUseConsistentWhitespace',
                      'PSUseCorrectCasing', 'PSAvoidGlobalVars', 'PSDeclareAsCmdletBinding')
    DisableRules = @()
}
"@ | Set-Content -Path $settingsPath -Encoding UTF8

Write-Host "  + PSScriptAnalyzerSettings.psd1"

# --- Summary ---
Write-Host "`n`n✅ Module '${ModuleName}' scaffolded successfully at:" -ForegroundColor Green
Write-Host "   $moduleFolder`n" -ForegroundColor Yellow

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. cd $ModuleName"
Write-Host "  2. Edit Public/*.ps1 to add your functions"
Write-Host "  3. Edit Private/*.ps1 for helper functions"
Write-Host "  4. Run tests: Invoke-Pester -Path ./Tests"
Write-Host "  5. Commit: git init && git add . && git commit -m 'Initial module scaffold'"