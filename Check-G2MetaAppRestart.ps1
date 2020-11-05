#Region Preconfigure
USING MODULE .\ServicesHelpers.psm1

$Console = $Host.UI.RawUI 
$Buffer = $Console.BufferSize  
$Buffer.Width = '4096'
$Console.BufferSize = $Buffer 

$ServersList = $ENV:G2_Meta.Split(",")
$Username    = $ENV:ADMIN
$Password              = ConvertTo-SecureString $ENV:PASS -AsPlainText -Force 
$Credentials           = New-Object System.Management.Automation.PSCredential ($Username, $Password)
$HTMLpath               = "$env:OutputsForMetaStack\G2-Meta-App-Restart-Check\OutputG2MetaProc.html"
#Endregion Preconfigure


#Region Execute
$Result = @();
foreach ($srv in $ServersList) 
{
    $metaserver = [MetaServerRestarter]::new($srv, $Credentials);    
    $metaserver.GetLastBootTime();
    $Result += $metaserver;     
}
#Endregion Execute


#Region ExportHTML
if($Result -ne $null -and $Result[0] -ne $null) {  
  
  if([Functions]::ExportHtmlFile( $Result, $HTMLpath, ( [Properties]::CheckMetaProps ))) 
    {Write-Output "HTML exported to $HostName / $HTMLpath"}
  else
    {Write-Output "Error during HTML export" }
}
#EndRegion ExportHTML
   

#Region DisplayResults

return ($Result | Format-Table -Wrap -Property ( [Properties]::CheckMetaProps ) | Out-String )  

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
