$sampleXmlPath = "$env:TEMP\sample.xml"
@"
<?xml version="1.0" encoding="utf-8"?>
<root>
    <customer id="1">
        <name>John Doe</name>
        <email>john@example.com</email>
        <orders>
            <order id="101">
                <product>Laptop</product>
                <price>999.99</price>
            </order>
            <order id="102">
                <product>Mouse</product>
                <price>24.99</price>
            </order>
        </orders>
    </customer>
    <customer id="2">
        <name>Jane Smith</name>
        <email>jane@example.com</email>
        <orders>
            <order id="201">
                <product>Monitor</product>
                <price>349.99</price>
            </order>
        </orders>
    </customer>
</root>
"@ | Out-File -FilePath $sampleXmlPath -Encoding utf8

Write-Host "Sample XML file created at: $sampleXmlPath" -ForegroundColor Cyan

# Load the XML file
try {
    [xml]$xml = Get-Content -Path $sampleXmlPath -ErrorAction Stop
    Write-Host "XML file loaded successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Error loading XML file: $_" -ForegroundColor Red
    exit
}

# Get the root element
$root = $xml.DocumentElement

# =========================================
# Method 3: Recursive iteration through the entire XML structure
# =========================================
Write-Host "`n--- Method 3: Recursive iteration through the entire XML structure ---" -ForegroundColor Green

function Show-XmlNode {
    param (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode]$Node,
        
        [int]$Depth = 0
    )
    
    # Create indentation based on depth
    $indent = "  " * $Depth
    
    # Display the current node
    $nodeType = if ($Node.NodeType -eq "Element") { "Element" } else { $Node.NodeType }
    $nodeInfo = "$indent[$nodeType] $($Node.Name)"
    
    # Add attributes if present
    if ($Node.Attributes -and $Node.Attributes.Count -gt 0) {
        $attrList = @()
        foreach ($attr in $Node.Attributes) {
            $attrList += "$($attr.Name)='$($attr.Value)'"
        }
        $nodeInfo += " (Attributes: $($attrList -join ", "))"
    }
    
    Write-Host $nodeInfo -ForegroundColor $(if ($Depth -eq 0) { "Magenta" } else { "Cyan" })
    
    # Display text content if it's a text node or has direct text
    if ($Node.NodeType -eq "Text") {
        Write-Host "$indent  Text: $($Node.Value)" -ForegroundColor Gray
    }
    elseif ($Node.'#text' -and $Node.'#text'.Trim()) {
        Write-Host "$indent  Value: $($Node.'#text'.Trim())" -ForegroundColor Gray
    }
    
    # Recursively process child nodes
    foreach ($childNode in $Node.ChildNodes) {
        Show-XmlNode -Node $childNode -Depth ($Depth + 1)
    }
}

# Start the recursive display from the root
Write-Host "`nRecursively displaying the entire XML structure:"
Show-XmlNode -Node $root