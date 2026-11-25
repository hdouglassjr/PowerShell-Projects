# In your $PROFILE file:

# Import frequently used modules silently
Import-Module -Name PSReadLine -ErrorAction SilentlyContinue
Import-Module -Name Posh-Git   -ErrorAction SilentlyContinue  # Git integration in prompt

# Set PSReadLine options for better history and completion
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward