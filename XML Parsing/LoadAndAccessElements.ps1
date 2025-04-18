# First method
$xdoc1 = New-Object System.Xml.XmlDocument
$file = Resolve-Path -Path '.\XML Parsing\file.xml'
$xdoc1.Load($file)

# Second method
[xml] $xdoc2 = Get-Content  '.\XML Parsing\file.xml'

# Third method
$xdoc3 = [xml] (Get-Content -Path '.\XML Parsing\file.xml')

#$xdoc1.people
#$xdoc2.people.person
#$xdoc1.people.person[0].name

#  Accessing XML with XPath
# $xdoc1.SelectNodes("//people")
# $xdoc1.SelectNodes("//people//person")
$xdoc1.SelectNodes("//people//person[1]//name")
$xdoc1.SelectNodes("//people//person[2]//age")
$xdoc1.SelectNodes("//people//person[3]//@id")