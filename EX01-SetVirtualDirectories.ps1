$namespace = "smtp.address.pl"
$HOSTNAME = $env:computername

get-owavirtualdirectory | 
    select server,internalurl | 
        fl

set-owavitrualdirectory -identity "$HOSTNAME\OWA (Default Web Site)" -internalurl https://$namespace/owa
set-ecpvitrualdirectory -identity "$HOSTNAME\ECP (Default Web Site)" -internalurl https://$namespace/ecp
set-outlookanywhere -identity "$HOSTNAME\RPC (Default Web Site)" -internalhostname $namespace -internalclientsrequiressl $true -defaultauthenticationmethod ntlm
set-activesyncvitrualdirectory -identity "$HOSTNAME\Microsoft-Server-ActiveSync (Default Web Site)" -internalurl https://$namespace/Microsoft-Server-ActiveSync
set-webservicesvitrualdirectory -identity "$HOSTNAME\EWS (Default Web Site)" -internalurl https://$namespace/EWS/Exchange.asmx
set-oabvitrualdirectory -identity "$HOSTNAME\OAB (Default Web Site)" -internalurl https://$namespace/OAB
set-ecpvitrualdirectory -identity "$HOSTNAME\ECP (Default Web Site)" -internalurl https://$namespace/ecp
set-mapivitrualdirectory -identity "$HOSTNAME\mapi (Default Web Site)" -internalurl https://$namespace/mapi

Write-Host "After all changes:`n`n" -ForegroundColor Red

get-owavirtualdirectory | 
    select server,internalurl | 
        fl