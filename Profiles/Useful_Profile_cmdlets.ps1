$PROFILE | Format-List -Force

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
gcm -commandtype externalscript | Get-Item | 
Select-Object Directory,Name,Length,CreationTime,LastwriteTime,
@{name="Signature";Expression={(Get-AuthenticodeSignature $_.fullname).Status }}