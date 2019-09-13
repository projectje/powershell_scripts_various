Import-Module "$PSScriptRoot\MailGun.psm1" -Force

$from = "test@test.net"
$to = "test2@test.net"
$subject = "a mail with a subject"
$html = "this <b>test with attachments</b> text<br/> And another interesting line <hr />"
$attachments = @{
    "ExampleAttachment1.png" = 'c:\temp\whatapps.png'
    "AnotherExample.txt" = 'c:\temp\Msinfo.txt'
}

Send-MailgunEmail -from $from -to $to -subject $subject -htmlText $html -attachments $attachments
