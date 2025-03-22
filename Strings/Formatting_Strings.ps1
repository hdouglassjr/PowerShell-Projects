
$hash = @{ city = 'Berlin'}

# Option 1: Formatting a string with the -f operator.
$result = "You should visit {0}" -f $hash.city
Write-Output $result

# Option 2: Formatting with .NET static method.
$result2 = [String]::Format("You should visit {0}", $hash.city)
Write-Output $result2