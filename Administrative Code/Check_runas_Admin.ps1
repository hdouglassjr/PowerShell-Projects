


$IsAdmin = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains "S-1-5-32-544"
if ($IsAdmin) {
    Write-Output "Running as Administrator"
} else {
    Write-Output "Not running as Administrator"
}

if (-not ([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains "S-1-5-32-544") {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}