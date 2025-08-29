param(
    [string]$ComputerName = $env:COMPUTERNAME
)
$mmcArgs = 'services.msc /computer="{0}"' -f $ComputerName

try {
    # Launch Services MMC elevated (will prompt with UAC)
    Start-Process -FilePath "mmc.exe" -ArgumentList $mmcArgs -Verb RunAs -WorkingDirectory $env:SystemRoot
}
catch [System.ComponentModel.Win32Exception] {
    # 1223 = The operation was canceled by the user (UAC prompt declined)
    if ($_.Exception.NativeErrorCode -eq 1223) {
        Write-Host "UAC prompt canceled. Services window not opened."
    } else {
        throw
    }
}
catch {
    throw
}