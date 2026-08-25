function Get-ActualServerIp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [string]$DnsServer
    )

    try {
        $params = @{
            Name        = $ServerName
            Type        = 'A'
            ErrorAction = 'Stop'
        }

        if ($DnsServer) {
            $params.Server = $DnsServer
        }

        $records = Resolve-DnsName @params |
            Where-Object { $_.Type -eq 'A' }

        if (-not $records) {
            [pscustomobject]@{
                ServerName = $ServerName
                IPAddress  = $null
                Status     = 'No A record found'
            }
            return
        }

        $records | ForEach-Object {
            [pscustomobject]@{
                ServerName = $ServerName
                IPAddress  = $_.IPAddress
                Status     = 'OK'
            }
        }
    }
    catch {
        [pscustomobject]@{
            ServerName = $ServerName
            IPAddress  = $null
            Status     = $_.Exception.Message
        }
    }
}
