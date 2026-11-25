# Check if profile exists
Test-Path $PROFILE

# Create the profile file (and any missing parent directories)
if(-not (Test-Path $PROFILE)){
    New-Item -Path $PROFILE -ItemType File -Force
    Write-Output "Profile created at: $PROFILE"
}

# Open in Notepad for editing
# notepad $PROFILE

# Or open in VS Code
code $PROFILE
