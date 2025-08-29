<#
.SYNOPSIS
    This script retrieves the last 10 critical system events from the Windows Event Log.
.DESCRIPTION
    This script connects to the specified computers and retrieves the last 10 critical system events from the Windows Event Log.
#>
get-winevent -FilterHashtable @{Logname = 'System';Level=2} -MaxEvents 10 | sort-Object ProviderName,TimeCreated

