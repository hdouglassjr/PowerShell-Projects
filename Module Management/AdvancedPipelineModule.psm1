
# AdvancedPipelineModule.psm1
# A module demonstrating the practical use of begin, process, and end blocks.
# Usage:  Get-ChildItem -Filter *.psm1 | Measure-FileSize
function Measure-FileSize {
    [CmdletBinding()]
    param (
        # This parameter accepts file paths from the pipeline.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [string]$Path
    )

    begin {
        # This block runs ONCE before any pipeline input.
        # We initialize the total size and the count of files processed.
        $totalSize = 0
        $fileCount = 0
        Write-Verbose "Starting file size measurement..."
    }

    process {
        # This block runs FOR EACH item from the pipeline.
        try {
            # Resolve the path to handle wildcards, then get the file object.
            $resolvedPath = Resolve-Path $Path -ErrorAction Stop
            $file = Get-Item $resolvedPath -ErrorAction Stop

            # Ensure we only process files, not directories
            if ($file -is [System.IO.FileInfo]) {
                 Write-Host ("Processing: " + $file.FullName)
                 $totalSize += $file.Length
                 $fileCount++
            }
        }
        catch {
            Write-Warning "Could not process path '$Path'. Error: $_"
        }
    }

    end {
        # This block runs ONCE after all items have been processed.
        # We display the final summary.
        $totalSizeInMB = $totalSize / 1MB
        Write-Host "`n--- Measurement Complete ---"
        Write-Host ("Total Files Processed: " + $fileCount)
        Write-Host ("Total Size: " + $totalSizeInMB.ToString("F2") + " MB")
    }
}

# Export the function to make it available when the module is imported.
Export-ModuleMember -Function Measure-FileSize

