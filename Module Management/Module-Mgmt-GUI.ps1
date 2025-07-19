Add-Type -AssemblyName PresentationFramework

function Show-ModuleVersionGui {
    param (
        [string]$ModuleName = 'PSReadLine'
    )

    $available = Get-Module -ListAvailable -Name $ModuleName | Sort-Object Version -Descending
    if (-not $available) {
        [System.Windows.MessageBox]::Show("Module '$ModuleName' not found.", "Error")
        return
    }

    # Create Window
    $window = New-Object Windows.Window
    $window.Title = "Manage Module Versions - $ModuleName"
    $window.Width = 500
    $window.Height = 250
    $window.WindowStartupLocation = 'CenterScreen'

    # Create Grid with rows
    $grid = New-Object Windows.Controls.Grid
    $grid.Margin = '10'

    for ($i = 0; $i -lt 4; $i++) {
        $rowDef = New-Object Windows.Controls.RowDefinition
        $rowDef.Height = 'Auto'
        $grid.RowDefinitions.Add($rowDef)
    }

    # ComboBox for versions
    $comboBox = New-Object Windows.Controls.ComboBox
    foreach ($mod in $available) {
        $comboBox.Items.Add("Version $($mod.Version) | $($mod.Path)")
    }
    $comboBox.SelectedIndex = 0
    [Windows.Controls.Grid]::SetRow($comboBox, 0)
    $grid.Children.Add($comboBox)

    # Label for current version
    $currentModule = Get-Module -Name $ModuleName
    $currentLabel = New-Object Windows.Controls.TextBlock
    $currentLabel.Text = "Current Loaded Version: " + ($currentModule?.Version ?? 'None')
    $currentLabel.Margin = '0,10,0,10'
    [Windows.Controls.Grid]::SetRow($currentLabel, 1)
    $grid.Children.Add($currentLabel)

    # Button to switch
    $loadButton = New-Object Windows.Controls.Button
    $loadButton.Content = "Switch to Selected Version"
    $loadButton.Margin = '0,10,0,10'
    $loadButton.Height = 30
    [Windows.Controls.Grid]::SetRow($loadButton, 2)
    $grid.Children.Add($loadButton)

    # Button click event
    $loadButton.Add_Click({
        $selected = $comboBox.SelectedItem.ToString() -split '\|' | Select-Object -First 1
        $version = ($selected -replace '[^\d\.]', '').Trim()

        Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
        try {
            Import-Module -Name $ModuleName -RequiredVersion $version -ErrorAction Stop
            [System.Windows.MessageBox]::Show("Loaded version $version successfully.", "Success")
            $window.Close()
        } catch {
            [System.Windows.MessageBox]::Show("Failed to load version $version.`n$($_.Exception.Message)", "Error")
        }
    })

    # Set grid content and show
    $window.Content = $grid
    $window.ShowDialog()
}

Show-ModuleVersionGui -ModuleName 'dbatools'