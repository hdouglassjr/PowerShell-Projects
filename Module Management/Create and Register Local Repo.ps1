New-Item -Path $RepoPath -ItemType Directory -Force
Copy-Item "$ProjectRoot\nupkg\$ModuleName.$ModuleVersion.nupkg" -Destination $RepoPath -Force

# Register only once
if (-not (Get-PSRepository -Name LocalNuget -ErrorAction SilentlyContinue)) {
    Register-PSRepository -Name LocalNuget -SourceLocation $RepoPath -InstallationPolicy Trusted
}


# Usage:
# 1. Run this script to create and register the local repo
# 2. Install the module from the local repo
Install-Module -Name $ModuleName -Repository LocalNuget -Scope CurrentUser -Force