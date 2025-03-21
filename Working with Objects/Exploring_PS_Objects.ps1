# Use Get-Member to see what an object is and contains, like propertie and methods.
Get-Item C:\Windows | Get-Member

# Another way to write it.
$Object = Get-Item C:\Windows
$Object.GetType()

# List just all the properties of the object.
Get-Item C:\Windows | Format-List -Property *

# Creating and adding a property to an Object
$obj = New-Object -TypeName psobject -Property @{
    Name = $env:USERNAME
    ID = 12
    Address = $null
}
Add-Member -InputObject $obj -Name "SomeNewProp" -Value "A Value" -MemberType NoteProperty
Write-Output $obj

# Create a new object from the last object and add a calculated property using Select-Object
$newObject = $obj | Select-Object *, @{ label='SomeOtherProp'; Expression={'Another Value'}}
Write-Output $newObject

# We can use shorthand of the Select-Object as shown.
$newObject2 = $obj | Select-Object *, @{ l='SomeMoreProp';e={'Some more value.'}}
$newObject2