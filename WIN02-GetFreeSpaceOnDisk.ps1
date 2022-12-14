# $servers = Get-ExchangeServer | 
#	select -ExpandProperty name
$servers = $(hostname)

$assignedLetter = "C"

foreach ($server in $servers)
{
	write-host "======================================================================" -foregroundcolor green
	write-host "                           $server" -foregroundcolor green
	write-host "======================================================================" -foregroundcolor green
	
	$disks = $server | 
		% {Get-WmiObject win32_volume -ComputerName $_ | 
			? {$_.name -like "$($assignedLetter):\*"}}

	$line = ""
	$line += "{0,22}" -f "Path"
	$line += "{0,15}" -f "Capacity"
	$line += "{0,15}" -f "FreeSpace"
	$line += "{0,17}" -f "FreeSpace (%)"
	write-host "----------------------------------------------------------------------"
	write-host $line
	write-host "----------------------------------------------------------------------"
	foreach ($disk in $disks){
		$name = $disk.name
		$capacity = "$([math]::Round($disk.capacity/1GB)) GB"
		$freespace = "$([math]::Round($disk.freespace/1GB, 2)) GB"
		$percent = [math]::Round($disk.freespace/$disk.capacity, 2)*100

		$line = ""
		$line += "{0,22}" -f "$name"
		$line += "{0,15}" -f "$capacity"
		$line += "{0,15}" -f "$freespace"
		$line += "{0,17}" -f "$percent%"

		if ($percent -lt 15)
		{
			write-host $line -foregroundcolor darkred
		}
		else
		{
			write-host $line
		}
	}
	write-host
}