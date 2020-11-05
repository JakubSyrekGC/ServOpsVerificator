USING MODULE .\ServicesHelpers.psm1

$Console                  = $Host.UI.RawUI 
$Buffer                   = $Console.BufferSize  
$Buffer.Width             = '4096'
$Console.BufferSize       = $Buffer 

$ServersList              = $ENV:G2_Meta.Split(",")
$Username                 = $ENV:ADMIN
$Password                 = ConvertTo-SecureString $ENV:PASS -AsPlainText -Force 
$Credentials              = New-Object System.Management.Automation.PSCredential ($Username, $Password)
$HTMLpath                 = "$env:OutputsForMetaStack\MT_TB_Conn\OutputTBConn.html"
#Endregion Preconfigure


#Region Execute
$Result = @() ;

foreach ($srv in $ServersList) 
{
    $ConnChecker = [ConnChecker]::new($srv, $credentials)    
    $ConnChecker.GetConnectivityStatus()                 
    $Result += $ConnChecker                                      
}

#Endregion Execute


#Region ExportHTML
if ($Result -ne $null -and $Result[0] -ne $null) {  
  
  if([Functions]::ExportHtmlFile( $Result, $HTMLpath, ( [Properties]::CheckConnProps ))) 
    {Write-Output "HTML exported to $HTMLpath"}
  else
    {Write-Output "Error during HTML export" }
}
#EndRegion ExportHTML


#Region DisplayResults

return ($Result | Format-Table -Wrap -Property ( [Properties]::CheckConnProps ) | Out-String )  

#Endregion DisplayResults 
