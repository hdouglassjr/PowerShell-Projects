# Get all drives identified by a standard drive letter. I'm suppressing errors to ignore non-existent drive letters.
Get-WmiObject Win32_LogicalDisk -ErrorAction SilentlyContinue | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
    [PSCustomObject]@{
        DeviceID   = $_.DeviceID
        VolumeName  = $_.VolumeName
        FileSystem  = $_.FileSystemType
        SizeGB      = [math]::round($_.Size / 1GB, 2)
        FreeSpaceGB = [math]::round($_.FreeSpace / 1GB, 2)
    }
}

get-volume -driveletter (97..122) -ErrorAction SilentlyContinue

gcim win32_computersystem -computer SRV1,SRV2 | Select PSComputername,@{Name="Memory";Expression={$_.TotalPhysicalMemory/1GB -as [int]}}