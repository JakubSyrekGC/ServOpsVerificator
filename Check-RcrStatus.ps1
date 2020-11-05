#Region Preconfigure
USING MODULE .\ServicesHelpers.psm1

$ServersList           = $ENV:RCR_Servers.Split(",")
$Username              = $ENV:ADMIN
$Password              = ConvertTo-SecureString $ENV:PASS -AsPlainText -Force 
$Credentials           = New-Object System.Management.Automation.PSCredential ($Username, $Password)
$HTMLpath              = "$env:OutputsForMetaStack\RCR_Status\OutputRCRStatus.html"
#Endregion Preconfigure


#Region Execute
$Result = @()

foreach ($srv in $ServersList) 
{
    $RCRChecker = [RCRChecker]::new($srv, $credentials);    
    $RCRChecker.GetRcrStatus()
    $Result += $RCRChecker     
}
#Endregion Execute


#Region ExportHTML
if($Result -ne $null -and $Result[0] -ne $null) {  
  
  if([Functions]::ExportHtmlFile( $Result, $HTMLpath, ( [Properties]::CheckRCRProps ))) 
    {Write-Output "HTML exported to $HTMLpath"}
  else
    {Write-Output "Error during HTML export" }
}
#EndRegion ExportHTML


#Region DisplayResults

return ($Result | Format-Table -Wrap -Property ( [Properties]::CheckRCRProps ) | Out-String )  

#Endregion DisplayResults





