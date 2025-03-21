# Run netsh and get the raw output
$sslCertOutput = netsh http show sslcert

# Initialize an array to store the custom objects
$sslCertObjects = @()

# Initialize temporary variables for each property
$ipPort = $null
$certHash = $null
$appId = $null

# Loop through each line of the output
foreach ($line in $sslCertOutput) {
    # Trim leading/trailing whitespace for easier parsing
    $trimmedLine = $line.Trim()

    # Detect and capture the IP:Port line
    if ($trimmedLine -match '^\s*IP:port\s+:\s+(\d+\.\d+\.\d+\.\d+):(\d+)') {
        $ipPort = $Matches[1,2]
    }

    # Detect and capture the Certificate Hash line
    elseif ($trimmedLine -match "^Certificate Hash\s+:\s+(?<certhash>.+)$") {
        $certHash = $Matches['certhash']
    }

    # Detect and capture the Application ID line
    elseif ($trimmedLine -match "^Application ID\s+:\s+{(?<appid>.+)}$") {
        $appId = $Matches['appid']

        # Once we have IPPort, CertHash, and AppId, create the object
        $sslCertObject = [PSCustomObject]@{
            IPPort   = $ipPort
            CertHash = $certHash
            AppId    = $appId
        }

        # Add the object to our array
        $sslCertObjects += $sslCertObject

        # Reset variables for the next block
        $ipPort = $null
        $certHash = $null
        $appId = $null
    }
}

# Output the results
$sslCertObjects | Where-Object {$_.IPPort -eq "44300"} | Select-Object AppId

#TODO: Log all output so app id is at least logged before removing binding
