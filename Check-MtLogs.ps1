#Region Preconfigure
USING MODULE .\ServicesHelpers.psm1
$Console = $Host.UI.RawUI 
$Buffer = $Console.BufferSize  
$Buffer.Width = '4096'
$Console.BufferSize = $Buffer 
$newLine = [Environment]::NewLine
$Properties = ("ServerName,TradeCont").Split(",")
$HTMLpath = "$env:OutputsForMetaStack\G2-Meta-App-Restart-Check\OutputG2MetaProc.html"
$HostName = [System.Net.Dns]::GetHostName()
$bar = Write-Output "$newLine#####################################################################################################################$newLine"
#Endregion Preconfigure

$bar
#Region Execute
$ServersList = $env:G2_Meta_Servers
Write-Output "Servers: $ServersList $newLine" 
$Result = @()
$Result = [Functions]::CheckMetaLogs($ServersList)
#Endregion Execute


#Region ExportHTML
if($Result -ne $null -and $Result[0].TradeCont.Contains("error") -ne $true) {
  $bar
  if([Functions]::ExportHtmlFile( $Result, $HTMLpath, $Properties)) 
    {Write-Output "HTML exported to $HostName / $HTMLpath"}
  else
    {Write-Output "Error during HTML export" }
}
#EndRegion ExportHTML

$bar
#Region DisplayResults
[Functions]::DisplayResults($Result, $Properties)

#Endregion DisplayResults

$bar
#Region ReturnResultCodeFromScript
if($Result -ne $null -and $Result[0].TradeCont.Contains("error") -ne $true) {
    Write-Output "Logs successfully verified $bar"
    exit 0
}
else {
    Write-Output "Error! Logs not verified. Please check! $bar"
    exit 1
}
#Endregion ReturnResultCodeFromScript

