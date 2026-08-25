#Usage 1:
#  .\Get-ActualServerIp.ps1 -ServerName app01  
#  .\Get-ActualServerIp.ps1 -ServerName app01.corp.company.com -InternalDnsServer 10.10.20.15
#  .\Get-ActualServerIp.ps1 -ServerName app01.corp.company.com -InternalDnsServer 10.10.20.15 -ShowOnlyFinalIPs


[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ServerName,

    [string]$InternalDnsServer,

    [switch]$ShowOnlyFinalIPs
)

function Resolve-NameDetailed {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$DnsServer,

        [Parameter(Mandatory)]
        [string]$SourceLabel
    )

    $output = @()
    $visited = New-Object System.Collections.Generic.HashSet[string]
    $currentName = $Name
    $hop = 0

    while ($true) {
        $hop++

        if (-not $visited.Add($currentName)) {
            $output += [pscustomobject]@{
                Source      = $SourceLabel
                QueryName   = $Name
                Step        = $hop
                RecordType  = "LOOP"
                Name        = $currentName
                Target      = $null
                IPAddress   = $null
                Status      = "CNAME loop detected"
            }
            break
        }

        try {
            $params = @{
                Name        = $currentName
                ErrorAction = 'Stop'
            }

            if ($DnsServer) {
                $params.Server = $DnsServer
            }

            $results = Resolve-DnsName @params
        }
        catch {
            $output += [pscustomobject]@{
                Source      = $SourceLabel
                QueryName   = $Name
                Step        = $hop
                RecordType  = "ERROR"
                Name        = $currentName
                Target      = $null
                IPAddress   = $null
                Status      = $_.Exception.Message
            }
            break
        }

        $cnames = $results | Where-Object { $_.Type -eq 'CNAME' }
        $arecords = $results | Where-Object { $_.Type -eq 'A' }
        $aaaarecords = $results | Where-Object { $_.Type -eq 'AAAA' }

        foreach ($c in $cnames) {
            $output += [pscustomobject]@{
                Source      = $SourceLabel
                QueryName   = $Name
                Step        = $hop
                RecordType  = "CNAME"
                Name        = $c.Name
                Target      = $c.NameHost
                IPAddress   = $null
                Status      = "OK"
            }
        }

        foreach ($a in $arecords) {
            $output += [pscustomobject]@{
                Source      = $SourceLabel
                QueryName   = $Name
                Step        = $hop
                RecordType  = "A"
                Name        = $a.Name
                Target      = $null
                IPAddress   = $a.IPAddress
                Status      = "OK"
            }
        }

        foreach ($a in $aaaarecords) {
            $output += [pscustomobject]@{
                Source      = $SourceLabel
                QueryName   = $Name
                Step        = $hop
                RecordType  = "AAAA"
                Name        = $a.Name
                Target      = $null
                IPAddress   = $a.IPAddress
                Status      = "OK"
            }
        }

        if ($arecords -or $aaaarecords) {
            break
        }

        if ($cnames) {
            $currentName = $cnames[0].NameHost.TrimEnd('.')
            continue
        }

        $output += [pscustomobject]@{
            Source      = $SourceLabel
            QueryName   = $Name
            Step        = $hop
            RecordType  = "NONE"
            Name        = $currentName
            Target      = $null
            IPAddress   = $null
            Status      = "No A, AAAA, or CNAME records found"
        }
        break
    }

    return $output
}

$results = @()

$results += Resolve-NameDetailed -Name $ServerName -SourceLabel "Local Resolver"

if ($InternalDnsServer) {
    $results += Resolve-NameDetailed -Name $ServerName -DnsServer $InternalDnsServer -SourceLabel "Internal DNS ($InternalDnsServer)"
}

if ($ShowOnlyFinalIPs) {
    $results |
        Where-Object { $_.RecordType -in @('A', 'AAAA') } |
        Sort-Object Source, IPAddress -Unique |
        Format-Table -AutoSize
}
else {
    $results |
        Format-Table Source, QueryName, Step, RecordType, Name, Target, IPAddress, Status -AutoSize
}
