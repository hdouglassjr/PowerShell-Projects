# See which versions of PSReadLine are installed and where
Get-Module -ListAvailable -Name PSReadLine | Select-Object Name, Version, Path

#  Retrieve dependencies of a module recursively as file system paths or module data types
Get-ModuleDependency -Module (Get-Module PSReadLine)

# Check if a specific module has an update
Update-Module -Name 'PSReadLine' -WhatIf

# List All Installed Modules with Potential Updates
Get-InstalledModule | Update-Module -WhatIf

# To see the version your current session is using:
(Get-Module -Name PSReadLine).Version

#  Check to see all loaded modules in the current session
Get-Module | Select-Object Name, Version, Path

# Add a module to the current session, then re-run last command to see it listed
Import-Module -Name dbatools

# Find modules with Get verbs
Get-command -Module dbatools -Verb Get

# Find commands in a module that contain certain text
Get-command -Module dbatools -Name "*stored*"

# List what Versions Are Available on Disk
Get-Module -ListAvailable -Name dbatools | Select-Object Name, Version, Path

# Manually import a specific version if more than one is installed
Import-Module -Name dbatools -RequiredVersion 2.1.32

# If it's not loaded as expected, use:
# Note: Just make sure no other dependent scripts or tools assume the newer version—you might want to check compatibility first!
Remove-Module PSReadLine
Import-Module PSReadLine -RequiredVersion 2.1.0

<#
🧹 Should You Uninstall Older Versions?
That depends on your workflow:
- ✅ Keep older versions if you're testing backwards compatibility or have legacy scripts.
- ❌ Uninstall them if you want to reduce clutter or enforce consistency.
To uninstall a specific version:
Uninstall-Module PSReadLine -RequiredVersion 2.1.0

You can list installed versions first with:
Get-InstalledModule -Name PSReadLine -AllVersions

Then selectively remove as needed.

Would it help if I bundled this into a reusable helper function that audits and switches module versions interactively? I think it would suit your style of methodical troubleshooting and help streamline your sessions.

#>

# You can list installed versions first with:
Get-InstalledModule -Name PSReadLine -AllVersions

# Then selectively remove as needed.
# Uninstall a specific version:
Uninstall-Module PSReadLine -RequiredVersion 2.1.0