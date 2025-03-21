Add-Type -AssemblyName PresentationFramework
[xml]$XAMLWindow = '
<Window
 xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
 xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
 Height="Auto"
 SizeToContent="WidthAndHeight"
 Title="Get-Service">
 <ScrollViewer Padding="10,10,10,0" ScrollViewer.VerticalScrollBarVisibility="Disabled">
 <StackPanel>
 <StackPanel Orientation="Horizontal">
 <Label Margin="10,10,0,10">ComputerName:</Label>
 <TextBox Name="Input" Margin="10" Width="250px"></TextBox>
 </StackPanel>
 <DockPanel>
 <Button Name="ButtonGetService" Content="Get-Service" Margin="10" Width="150px"
IsEnabled="false"/>
 <Button Name="ButtonClose" Content="Close" HorizontalAlignment="Right" Margin="10"
Width="50px"/>
 </DockPanel>
 </StackPanel>
 </ScrollViewer >
</Window>
'
#Create Window Object
$Reader = (New-Object System.Xml.XmlNodeReader $XAMLWindow)
$Window = [Windows.Markup.XamlReader]::Load($Reader)

$Window.ShowDialog() | Out-Null