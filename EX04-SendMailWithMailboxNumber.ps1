$mbx = get-mailbox -resultsize unlimited

$noOfMbx = $mbx | 
    measure | 
        select -ExpandProperty count

$recipients = ("admin1@domain.com", "admin2@domain.com", "admin3@domain.com", "admin4@domain.com")
$smtpaddress = "smtp.server.domain.com"
$from = "num_of_mailboxes@domain.com"

write-host "Liczba kont w MILNET-I: $($noOfMbx)" -ForegroundColor Green

foreach($recipient in $recipients)
{
    Send-MailMessage -Body "Number of mailboxes: $($noOfMbx)." -Encoding UTF-8 -SmtpServer $smtp -From $from -Subject "Number of mailboxes" -To $recipient
}

    