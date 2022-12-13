[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [String]$PrimarySMTPAddress,
    [Parameter(Mandatory = $false)]
    [Switch]$ExportToCSV = $false

)
 
$data = $primarysmtpaddress | 
    % {get-aduser -Properties proxyaddresses, canonicalname -filter "proxyaddresses -like '*$_*'" | 
        select @{n="Name"              ; e={($_.name)                                                                          }}, 
               @{n="PrimarySMTPAddress"; e={($_.proxyaddresses | ? {$_ -clike "SMTP*"}).split(":")[1]                          }}, 
               @{n="EmailAddresses"    ; e={($_.proxyaddresses | ? {$_ -like "smtp*$PrimarySMTPAddress*"})                     }},
               @{n="OrganizationalUnit"; e={($_.canonicalname).Substring(0, ($_.canonicalname).lastIndexOf('/')).substring(13) }}
      }

$data | 
    Format-Table

if($ExportToCSV)
{
    $data | 
        Export-Csv -Delimiter "," -Path ".\$(Get-Date -Format 'yyyy-MM-dd_hh-mm-ss')_aliases.csv"
}

