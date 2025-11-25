# Set these as needed
$ModuleName = "MyTool"
$ModuleVersion = "1.0.0"
$Author = "YourName"
$Description = "A cross-platform PowerShell 7+ module that does awesome stuff"
$ProjectRoot = "$PWD\$ModuleName"

@"
<?xml version="1.0"?>
<package >
  <metadata>
    <id>$ModuleName</id>
    <version>$ModuleVersion</version>
    <authors>$Author</authors>
    <description>$Description</description>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
  </metadata>
  <files>
    <file src="Public\*.ps1" target="content\$ModuleName\Public" />
    <file src="Private\*.ps1" target="content\$ModuleName\Private" />
    <file src="$ModuleName.psm1" target="content\$ModuleName" />
    <file src="$ModuleName.psd1" target="content\$ModuleName" />
  </files>
</package>
"@ | Out-File -FilePath "$ProjectRoot\$ModuleName.nuspec" -Encoding utf8 -Force
# 7. Pack the module into a .nupkg
nuget pack "$ProjectRoot\$ModuleName.nuspec" -OutputDirectory "$ProjectRoot\nupkg"
