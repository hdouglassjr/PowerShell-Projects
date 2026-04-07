function Get-ActualServerIp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [string]$InternalDnsServer
    )

    $allResults = @()

    try {
        $local = Resolve-DnsName -Name $ServerName -Type A -ErrorAction Stop |
            Where-Object { $_.Type -eq 'A' } |
            Select-Object @{Name='Source';Expression={'Local Resolver'}},
                          @{Name='ServerName';Expression={$ServerName}},
                          @{Name='IPAddress';Expression={$_.IPAddress}}

        $allResults += $local
    }
    catch {}

    if ($InternalDnsServer) {
        try {
            $internal = Resolve-DnsName -Name $ServerName -Type A -Server $InternalDnsServer -ErrorAction Stop |
                Where-Object { $_.Type -eq 'A' } |
                Select-Object @{Name='Source';Expression={"DNS $InternalDnsServer"}},
                              @{Name='ServerName';Expression={$ServerName}},
                              @{Name='IPAddress';Expression={$_.IPAddress}}

            $allResults += $internal
        }
        catch {}
    }

    if ($allResults.Count -eq 0) {
        Write-Error "No DNS results found for $ServerName"
        return
    }

    $allResults | Sort-Object Source, IPAddress -Unique
}
