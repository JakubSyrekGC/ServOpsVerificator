class MetaServerRestarter {
    [string]$ServerName
    [string]$MetaServer
    [string]$MetaAdminAPIService
    [string]$MetaRatesCenter
    [string]$MetaRefRateIndicator
    [string]$TibRVD
       

    MetaServerRestarter(
    [string]$sn,
    [string]$ms,
    [string]$maas,
    [string]$mrc,
    [string]$mrri,
    [string]$t
    
    ){
        $this.ServerName = $sn
        $this.MetaServer = $ms
        $this.MetaAdminAPIService = $maas
        $this.MetaRatesCenter = $mrc
        $this.MetaRefRateIndicator = $mrri
        $this.TibRVD = $t        
     }
}

class Filter
{
    static [string]$MetaAdminAPIService  = "Name='MetaAdminAPIService.exe'"   
    static [string]$MetaRatesCenter      = "Name='MetaRatesCenter.exe'"          
    static [string]$MetaRefRateIndicator = "Name='MetaRefRateIndicator.exe'"
    static [string]$mtsrv                = "Name='mtsrv.exe'"               
    static [string]$rvntsctl             = "Name='rvntsctl.exe'"             
  
}

function Get-LastBootUpTime {
    param(
        [string]$Server,
        [System.Management.Automation.PSCredential]$Credentials,
        [string]$Filter              
    )
        
    if ([string]::IsNullOrEmpty($Server) -or [string]::IsNullOrEmpty($Server) -or $Credentials -eq [System.Management.Automation.PSCredential]::Empty) {return $null}

    [string]$result = $null

    try
    {
        $result = gwmi win32_process -computer $Server -Credential $Credentials -filter $Filter -ErrorAction Stop | Select @{Name="Started";Expression={$_.ConvertToDateTime($_.CreationDate)}}| ft -hidetableheaders | out-string 
    }
    catch [System.Runtime.InteropServices.COMException]
    {
        if($_.Exception.ErrorCode -eq 0x800706BA)
        {       
           $result = "The RPC server is unavailable"           
        }        
        
    }
    catch [System.UnauthorizedAccessException]
    {
        $result = "Access is denied"         
    }
    catch [System.Exception]
    {
        $result = $_.Exception.ErrorCode
    }
    return $result
}




#Region Consts
$erroractionpreference = "SilentlyContinue" 
$srv                  =  'MT4106Demo'
$username    = $env:User #broken
$password    = ConvertTo-SecureString $env:Pass -AsPlainText -Force #broken
$credentials = New-Object System.Management.Automation.PSCredential ($username, $password)
$HTML | out-null
$Result = @()
$Date = (get-date).AddHours(-10) 
#EndRegion Consts

#$MetaAdminAPIService1 = $null
#$MetaRatesCenter1 = $null
#$MetaRefRateIndicator1 = $null
#$mtsrv1 = $null
#$TibRVD1 = $null


#foreach ($srv in $computername) 
#{
            
    $MetaAdminAPIService1 =  (Get-LastBootUpTime -Server $srv -Filter ([Filter]::MetaAdminAPIService) -Credentials $credentials ).Trim()
    $MetaRatesCenter1 =      (Get-LastBootUpTime -Server $srv -Filter ([Filter]::MetaRatesCenter)     -Credentials $credentials ).Trim()
    $MetaRefRateIndicator1 = (Get-LastBootUpTime -Server $srv -Filter ([Filter]::MetaRefRateIndicator)-Credentials $credentials ).Trim()
    $mtsrv1 =                (Get-LastBootUpTime -Server $srv -Filter ([Filter]::mtsrv)               -Credentials $credentials ).Trim()
    $TibRVD1 =               (Get-LastBootUpTime -Server $srv -Filter ([Filter]::MetaAdminAPIService) -Credentials $credentials ).Trim()
    
    $restarter = [MetaServerRestarter]::new( $srv.Trim(), $mtsrv1, $MetaAdminAPIService1,  $MetaRatesCenter1, $MetaRefRateIndicator1, $TibRVD1)
    $Result += $restarter
#}

($Result | Format-Table -Wrap | Out-String )    
    
