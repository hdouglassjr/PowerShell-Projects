# Common Errors and Fixes

- **Profile won’t load** — execution policy blocks it: If PowerShell shows “File cannot be loaded because running scripts is disabled,” the execution policy is preventing your profile from running. Fix it with: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`. This allows locally created scripts (including your profile) to run while still requiring signatures on downloaded scripts.
- **Wrong profile path for PowerShell 7 vs Windows PowerShell**: Changes you make to `$PROFILE` list item in a Windows PowerShell session only affect that host. If your aliases and functions aren’t appearing in PowerShell 7, you’re editing the wrong file. Always confirm which host you’re in with `$PSVersionTable.PSVersion` before editing a profile.

### Reference
- [https://www.powershelltips.com/powershell-profile-setup/](url)