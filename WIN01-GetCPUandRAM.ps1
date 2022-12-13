$servers = (get-exchangeserver).name
$servers = $(hostname)

foreach($svr in $servers)
{
    write-host "RAM: " -ForegroundColor Green

    if($(hostname) -ne $servers)
    {
        $ram = Invoke-Command -ComputerName $svr -ScriptBlock {
            Get-CimInstance win32_physicalmemory | 
                Select-Object -ExpandProperty Capacity | 
                    ForEach-Object { "$($_/1GB) GB" }
                    }
    }
    else
    {
        $ram = Get-CimInstance win32_physicalmemory | 
            Select-Object -ExpandProperty Capacity | 
                ForEach-Object { "$($_/1GB) GB" }
    }

    $sum = $ram | 
        ForEach-Object {$_.split(" ")[0]} | 
            Measure-Object -Sum | 
                Select-Object -ExpandProperty sum

    $ram | 
        ForEach-Object { Write-Host $_ }
    write-host "SUM: $sum GB"

    if($(hostname) -ne $servers)
    {
        Invoke-Command -ComputerName $_ -ScriptBlock {
            Get-CimInstance cim_processor | 
                select Name, @{n="ClockSpeed"; e={"$([Math]::Round($_.maxclockspeed/1024,2)) GHz"}}
                }
    }
    else
    {
        Get-CimInstance cim_processor | 
            select Name, @{n="ClockSpeed"; e={"$([Math]::Round($_.maxclockspeed/1024,2)) GHz"}}
    }
}


