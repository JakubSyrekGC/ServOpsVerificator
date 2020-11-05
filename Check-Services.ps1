#Region Preconfigure
USING MODULE .\ServicesHelpers.psm1

$Console = $Host.UI.RawUI 
$Buffer = $Console.BufferSize  
$Buffer.Width = '4096'
$Console.BufferSize = $Buffer 

$ServersList = $ENV:MT5_Start.Split(",") #SERVERS_LIST
$Username    = $ENV:ADMIN
$Password              = ConvertTo-SecureString $ENV:PASS -AsPlainText -Force 
$Credentials           = New-Object System.Management.Automation.PSCredential ($Username, $Password)

$HTMLpath = "$env:OutputsForMetaStack\G2-Meta-App-Restart-Check\OutputG2MetaProc.html"
#Endregion Preconfigure


$Result = @()

foreach ($srv in $ServersList) 
{
    $metaserver = [MetaServerChecker]::new($srv, $credentials);    
    $metaserver.GetLastBootTime()
    $Result += $metaserver     
}   



#Region ExportHTML
if($Result -ne $null -and $Result[0] -ne $null) {  
  
  if([Functions]::ExportHtmlFile( $Result, $HTMLpath, ([Properties]::CheckMt5ServicesProps) )) 
    {Write-Output "HTML exported to $HostName / $HTMLpath"}
  else
    {Write-Output "Error during HTML export" }
}
#EndRegion ExportHTML

$bar
#Region DisplayResults
return ($Result | Format-Table -Wrap -Property ([Properties]::CheckMt5ServicesProps)  | Out-String )  

#Endregion DisplayResults


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



