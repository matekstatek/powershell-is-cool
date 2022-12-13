param(
    [parameter(Mandatory=$true)]
    [string]$DisplayName,
    [parameter(Mandatory=$false)]
    [string]$dot=$false
)

function Remove-DiacriticsAndSpaces
{
    Param
    (
        [String]$inputString
    )

    $objD = $inputString.Normalize([Text.NormalizationForm]::FormD)
    $sb = New-Object Text.StringBuilder
 
    for ($i = 0; $i -lt $objD.Length; $i++) 
    {
        $c = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($objD[$i])
        
        if($c -ne [Globalization.UnicodeCategory]::NonSpacingMark) 
        {
            [void]$sb.Append($objD[$i])
        }
    }
    
    return($sb -replace '[^a-zA-Z0-9]', '')
}

function Get-FreeAlias
{
    Param
    (
        [String]$displayName,
        [String]$dot = $false
    )

    $imie = $displayName.Split(" ")[0].ToLower()
    $nazwisko = $displayName.Split(" ")[1].ToLower()
    $flag = $false
    $i = 0

    $imie = Remove-DiacriticsAndSpaces -inputString $imie
    $nazwisko = Remove-DiacriticsAndSpaces -inputString $nazwisko

    $stop = $imie.length

    while ($i -lt $stop)
    {
        $alias = ""

        for($j=0; $j -le $i; $j++)
        {
            $alias += $imie[$j]
        }

        if ($dot -eq $true)
        {
            $alias += "."
        }

        $alias += $nazwisko
        $isexist = get-content alias.txt

        if (-not ($isexist -contains $alias))
        {
            $flag = $true
            break
        }

        $i++
    } 

    $counter = 1

    while ($flag -eq $false)
    {
        if ($dot -eq $false)
        {
            $alias = $imie + $nazwisko + $counter
        }

        else
        {
            $alias = $imie + "." + $nazwisko + $counter
        }

        $isexist = get-content alias.txt

        if (-not ($isexist -contains $alias))
        {
            $flag = $true
            break
        }

        $counter ++
    }

    return $alias
}

$alias = Get-FreeAlias -displayName $displayName -dot:$dot

write-host $alias