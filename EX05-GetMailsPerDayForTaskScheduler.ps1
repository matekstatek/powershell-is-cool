# skrypt powinien być odpalany codziennie o tej samej godzinie

# Biblioteka Exchange - import
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

# mail stuff
$from = "no-reply@domain.com"
$smtp = "smtp.server.domain.com"
$to = "admin1@domain.com"

# wrzucam pod zmienną "silently continue" - jeśli w danym momencie coś się wysypie w danym transport service, to nie wywali błędu
$ErrorActionPreference = "silentlycontinue"

# pobieram datę poprzedniego dnia
$day = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-1)

# wyciągam liczbę wysłanych maili od 00:00:00 poprzedniego dnia do 00:00:00 dzisiaj:
# dla każdego transport service wyciągnij wszystkie logi wiadomości,
# które nie były wysyłane do konto@fireeye.local lub z pustym adresatem (jak wiadomość jest
# wysyłana do kilku użytkowników, to exchange dzieli te wiadomości na pojedyncze, w tym
# zbiór pusty {} - jego też pomijamy
# następnie grupujemy maile po internalmessageid - każda wiadomość będzie miała inny,
# następnie zwracam liczbę tych elementów
$mailsPerDay = get-transportservice -ErrorAction $ErrorActionPreference | 
    Get-MessageTrackingLog -start $day -end $day.AddDays(1) -ResultSize Unlimited -ErrorAction $ErrorActionPreference | 
        ? {$_.recipients -notcontains "konto@fireeye.local" -and $_.internalmessageid -ne ""} | 
            group internalmessageid | 
                measure | 
                    select -ExpandProperty Count
    
# pod zmienną mailsperday znajduje się liczba elementów na wczorajszy dzień. Wrzucimy do pliku:

$log = ""
$name = ""
   
# jeżeli dzień jest mniejszy od 10 to dodajemy wcześniej 0, by mieć 01, 02, 03...
if($($day).day -lt 10)
{
    $log += "0"
}
    
$log += "$($($day).day)."

# to samo z miesiącem
if($($day).month -lt 10)
{
    $log += "0"
    $name += "0"
}

#some comment to test git

# name zawiera nazwę pliku
$name += "$($($day).month).$($($day).year)"

# log zawiera datę, średnik i liczbę wiadomości
$log += "$($($day).month).$($($day).year);$($mailsPerDay)"

# zawartość $log wrzucamy do pliku o nazwie $name - jeśli istnieje to dodajemy
# jako ostatnią linijkę, jeśli nie istnieje to tworzy nowy plik - dla nowego miesiąca
$log >> ".\$($name)_sentMails.csv"

# jeżeli wczorajszy dzień jest ostatnim dniem miesiąca, to zliczamy wszystkie maile z pliku
if ([DateTime]::DaysInMonth((Get-Date).Year, (Get-Date).Month) -eq (Get-Date).AddDays(-1).Day)
{
    $sum = 0

    #pobieramy zawartość pliku do zmiennej $text
    $text = Get-Content ".\$($name)_sentMails.csv"

    # dla każdej linijki z pliku
    foreach($line in $text)
    {
        # do sumy dodajemy drugi człon linijki (po średniku), np. dla 02.05.2022;2528 dodajemy do
        # sumy 2528
        $sum += [int]($line.split(";")[1])

    }

    # wysyłamy liczbę elementów do wyznaczonych osób
    Send-MailMessage -Body "Mails in a month $($name): $($sum)." -Encoding UTF-8 -SmtpServer $smtp -From $from -Subject "Num of mails in this month" -To $to
    Write-Host "Wysłano mail."
}
