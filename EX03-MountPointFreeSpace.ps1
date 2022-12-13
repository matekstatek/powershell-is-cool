$servers = Get-ExchangeServer | 
	select -ExpandProperty name

foreach($srvr in $servers)
{
	write-host ""

	$mountPoints = Get-WmiObject win32_volume -ComputerName $srvr | 
		? {$_.filesystem -match "refs"}
	
	write-host "------------------------------------------------------------------"
	write-host $srvr -foregroundcolor Green
	write-host "PATH`t`t`t`tCAPACITY`t`tFREE SPACE"
	write-host "------------------------------------------------------------------"
	foreach($mp in $mountPoints)
	{
		if ($([math]::Round($mp.freespace, 2)) -lt 200GB)
		{
			write-host "$($mp.name)`t`t$([math]::Round($mp.capacity/1GB, 2)) GB`t`t$([math]::Round($mp.freespace/1GB, 2)) GB`t`t(!!!)" -foregroundcolor Red
		}
		else
		{
			write-host "$($mp.name)`t`t$([math]::Round($mp.capacity/1GB, 2)) GB`t`t$([math]::Round($mp.freespace/1GB, 2)) GB"
		}
	}
}
write-host "------------------------------------------------------------------"