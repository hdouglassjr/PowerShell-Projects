# Discover available templates
Get-PlasterTemplate

# Create a new PowerShell module (interactive)
$template = Get-PlasterTemplate | Where-Object Name -eq NewPowerShellScriptModule
$moduleName = 'Company.Automation'

# Non-interactive with parameters
Invoke-Plaster -TemplatePath $template.TemplatePath -DestinationPath .\$moduleName `
    -ModuleName "$moduleName" -Version '1.0.0'