# In your $PROFILE file:

# Short aliases for common cmdlets
Set-Alias g Get-ChildItem
Set-Alias hist Get-History

# Alias to a function for complex shortcuts (aliases can't carry arguments)
function ll { Get-ChildItem -Force $args }
function touch { New-Item -ItemType File -Name $args[0] }
