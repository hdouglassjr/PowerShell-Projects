# Usage:
# Get-ActualServerIpComparison -ServerName "app01.corp.company.com" -InternalDnsServer "10.10.20.15"

function Get-ActualServerIpComparison {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$InternalDnsServer
    )

    function Get-FinalIPs {
        param(
            [string]$Name,
            [string]$DnsServer
        )

        $params = @{
            Name        = $Name
            ErrorAction = 'Stop'
        }

        if ($DnsServer) {
            $params.Server = $DnsServer
        }

        $results = Resolve-DnsName @params

        $ips = $results |
            Where-Object { $_.Type -in @('A', 'AAAA') } |
            Select-Object -ExpandProperty IPAddress -Unique

        if (-not $ips) {
            $cname = $results | Where-Object { $_.Type -eq 'CNAME' } | Select-Object -First 1
            if ($cname) {
                return Get-FinalIPs -Name $cname.NameHost.TrimEnd('.') -DnsServer $DnsServer
            }
        }

        return $ips
    }

    $localIPs = @()
    $internalIPs = @()

    try { $localIPs = Get-FinalIPs -Name $ServerName } catch {}
    try { $internalIPs = Get-FinalIPs -Name $ServerName -DnsServer $InternalDnsServer } catch {}

    [pscustomobject]@{
        ServerName      = $ServerName
        LocalResolverIP = ($localIPs -join ', ')
        InternalDnsIP   = ($internalIPs -join ', ')
        Match           = [bool](($localIPs | Sort-Object) -join ',' -eq ($internalIPs | Sort-Object) -join ',')
    }
}
