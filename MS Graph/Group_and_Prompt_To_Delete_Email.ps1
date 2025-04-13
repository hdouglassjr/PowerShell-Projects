# Connect to Microsoft Graph with Mail permissions
Connect-MgGraph -Scopes "Mail.ReadWrite"

# Get your profile to confirm connection
$me = Get-MgUserMe
Write-Host "Connected as: $($me.DisplayName) <$($me.UserPrincipalName)>`n"

# How many messages to fetch? (adjust as needed)
$topCount = Read-Host "How many messages do you want to scan? (Recommend: 500)"
if (-not [int]::TryParse($topCount, [ref]$null)) { $topCount = 500 }

Write-Host "`nFetching top $topCount messages from Inbox...`n"

# Get messages (you can specify additional filters if needed)
$mailMessages = Get-MgUserMessage -Top $topCount -Select "sender,subject"

if (-not $mailMessages) {
    Write-Host "No messages found!" -ForegroundColor Yellow
    return
}

# Group by sender email
$groupedSenders = $mailMessages | Group-Object -Property { $_.Sender.EmailAddress.Address }

# Display grouped senders sorted by email count
$sendersTable = $groupedSenders | Sort-Object Count -Descending | Select-Object @{Name="Sender";Expression={$_.Name}}, @{Name="EmailCount";Expression={$_.Count}}

# Display numbered list
for ($i = 0; $i -lt $sendersTable.Count; $i++) {
    $item = $sendersTable[$i]
    Write-Host "$($i + 1). $($item.Sender) - $($item.EmailCount) messages"
}

# Prompt for user input
$selection = Read-Host "`nEnter the number of the sender you want to delete messages from"
$selection = [int]$selection

if ($selection -lt 1 -or $selection -gt $sendersTable.Count) {
    Write-Host "Invalid selection. Exiting." -ForegroundColor Red
    return
}

$selectedSender = $sendersTable[$selection - 1].Sender
Write-Host "`nYou selected: $selectedSender`n"


# Confirm deletion
$confirm = Read-Host "Are you sure you want to delete ALL messages from $selectedSender? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    return
}

# Filter messages by selected sender
$messagesToDelete = $mailMessages | Where-Object { $_.Sender.EmailAddress.Address -eq $selectedSender }

if (-not $messagesToDelete) {
    Write-Host "No messages found from $selectedSender!" -ForegroundColor Yellow
    return
}

# Deleting messages
$messagesToDelete | ForEach-Object -Parallel {
    # $_ inside the parallel script block represents the item from the pipeline
    Remove-MgUserMessage -UserId $me -MessageId $_.Id -Confirm:$false
}


Write-Host "`nDeleted messages." -ForegroundColor Green
