# MyUtilityModule

A PowerShell module

## Installation

\\\powershell
Install-Module -Name MyUtilityModule -Scope CurrentUser
\\\

## Usage

\\\powershell
Get-MyUtilityModuleInfo
\\\

## Development

### Running tests

\\\powershell
cd MyUtilityModule
Invoke-Pester -Path ./Tests -Output Detailed
\\\

## License

Licensed under the [MIT License](LICENSE).
