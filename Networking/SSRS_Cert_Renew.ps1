$output = netsh http show sslcert
$parsedBindings = $output | ForEach-Object {
    if ($_ -match '^\s*IP:port\s+:\s+(\d+\.\d+\.\d+\.\d+):(\d+)') {
        if ($matches[2] -eq "44300") {
            [PSCustomObject]@{
                IPPort = $_
                ThumbPrint = $output[$output.IndexOf($_) + 1]
                AppId = $output[$output.IndexOf($_) + 2]
            }
            #$_  # This is the first line of the output for IP:port
            # $certHash = $output[$output.IndexOf($_) + 1]
            # Write-Output $certHash
            # $appId = $output[$output.IndexOf($_) + 2]
            # Write-Output $appId
        }
    }
}
$parsedBindings | Format-Table