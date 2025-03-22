
# Using backticks, which are escape characters then, r = return and n = newline
"Hello `r`nWorld!"

# Using the -f switch meaning format string and static method NewLine
"Hello{0}World!" -f [System.Environment]::NewLine

# Here-strings begin with @" and a linebreak and end with "@ on its own line 
# ("@must be first characters on the line, not even whitespace/tab)
@"
Hello
World
"@

# Here-string with quotes
@"
Simple
    Multi-line string
with "quotes".
"@

# Literal here-string
# You could also create a literal here-string by using single quotes, when you don't want any expressions to be
# expanded just like a normal literal string.
@'
The following line won't be expanded
$(Get-Date)
because this is a literal here-string
'@