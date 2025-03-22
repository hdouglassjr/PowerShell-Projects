# Strings are created by enclosing text in double quotes.
$myBasicString = "Some basic text."
$myBasicString

# Double-quoted strings can evaluate variables and special characters.
$name = "Harry"
$message = "Hello, $name!"
$message

# To use double-quotes inside a string enclosed in double-quotes, you use the escape character backtick `
$myString2 = "A `"double quoted`" string which also has 'single quotes'."
$myString2

## Literal String ##
#  Literal strings use 'single quotes' and do NOT evaluate variables or special characters.
$myLiteralString = 'Simple text including special characters (`n) and $variable-reference.'
$myLiteralString

# To use 'single quotes' in literal strings, use double-single-quotes or a literal here-string. 
$myLiteralString2 = 'Simple string with ''single quotes'' and "double quotes".'
$myLiteralString2

## Here-strings ##
#  Here-strings are enclosed in either double quotes ("@ and "@) 
#  for an expandable string (where variables and expressions are expanded) or single quotes ( and ) 
#  for a literal string (where everything is treated as plain text). 

# Expandable Here-String, in double-quotes making variables expandable, 
# meaning the variable's value is exposed when writing the string to output.
$expandableHereString = 
@"
This is an expandable here-string.
It can include variables, like $env:USERNAME.
"@
$expandableHereString

# Literal Here-String with surrounding text in single quotes that display text as is.
$literalHereString = @'
This is a literal here-string.
Variables like $env:USERNAME are not expanded.
'@
$literalHereString