# View all four profile path variables
$PROFILE.AllUsersAllHosts        # All users, all hosts
$PROFILE.AllUsersCurrentHost     # All users, current host (ISE or pwsh)
$PROFILE.CurrentUserAllHosts     # Current user, all hosts
$PROFILE.CurrentUser             # Current user, current host (most specific)

# Quick reference — show all paths
$PROFILE | Select-Object *
# or
$PROFILE | Format-List -Force

# You can also verify which PowerShell host you are running:
$Host.Name
# Example Outputs:
# In Visual Studio PCM:
# PM> $Host.Name
# Package Manager Host

<#
    List all PowerShell profile script settings. You will see different values for 
    different hosts, such as the PowerShell ISE, as well as between Windows PowerShell 
    and PowerShell 7.
    #>
$profile | Select-Object *host* | Format-List

# List all PowerShell profile script paths that exist.
# This will show you which profiles are available for editing.
($profile.psobject.properties).where({$_.name -ne 'length'}).where({Test-Path $_.value }) | Select-Object Name,Value

# Get details about all external scripts in your %PATH%.
Get-Command -CommandType ExternalScript | Get-Item | 
Select-Object Directory,Name,Length,CreationTime,LastWriteTime,
@{name="Signature";Expression={(Get-AuthenticodeSignature $_.fullname).Status }}