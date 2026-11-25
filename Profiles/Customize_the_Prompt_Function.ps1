# In your $PROFILE file:

function prompt {
    $currentPath = (Get-Location).Path
    # Abbreviate home directory as ~
    $currentPath = $currentPath -replace [regex]::Escape($HOME), "~"

    $gitBranch = ""
    if (Test-Path ".git") {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($branch) { $gitBranch = " [$branch]" }
    }

    # Blue path + yellow git branch + white PS>
    Write-Host $currentPath -ForegroundColor Blue -NoNewline
    Write-Host $gitBranch   -ForegroundColor Yellow -NoNewline
    return " PS> "
}