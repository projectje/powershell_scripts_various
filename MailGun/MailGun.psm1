<#
    .SYNOPSIS
        Interface to the Mailgun API Module

    .DESCRIPTION
        Sends an e-mail through the Mailgun API see https://documentation.mailgun.com/en/latest/user_manual.html#sending-via-api
        Define your maildomain and API key in MailGun.ps1 and place inside the module folder

    .EXAMPLE
        $from = "from@stackoverflow.com"
        $to = "to1@stackoverflow.com", "another@stackoverflow.com"
        $bcc = "bcc1@stackoveflow.com", "bcc2@stackoverflow.com"
        $subject = "a mail with a subject"
        $html = "this <b>test with attachments</b> text<br/> And another interesting line <hr />"
        $attachments = @{
            "ExampleAttachment1.png" = 'c:\temp\whatapps.png'
            "AnotherExample.txt" = 'c:\temp\Msinfo.txt'
        }
        Send-MailgunEmail -from $from -to -bcc $bcc $to -subject $subject -htmlText $html -attachments $attachments
#>
$ModuleData = Import-PowerShellDataFile "$PSScriptRoot\MailGun.psd1"

function ConvertTo-MimeMultiPartBody {
    <#
        .SYNOPSIS
            Convert email content with multiple attachments to correct format
            with help from https://stackoverflow.com/questions/45463391/sending-attachments-with-mailgun-using-powershell
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Boundary,

        [Parameter(Mandatory = $true)]
        [hashtable]
        $Data
    )

    $lb = "`r`n"
    $body = ""
    $Data.GetEnumerator() | ForEach-Object {
        $body += "--{0}{1}Content-Disposition: form-data; name=`"" -f $Boundary, $lb
        if ($_.Value -is [byte[]]) {
            $body += "attachment`"; filename=`"{0}`"{1}Content-Type: application/octet-stream{2}{3}{4}" -f
            $_.Key, $lb, $lb, $lb, [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetString($_.Value)
        }
        else {
            $body += "{0}`"{1}{2}{3}" -f $_.Key, $lb, $lb, $_.Value
        }
        $body += $lb
    }
    return "{0}{1}--{2}--" -f $lb, $body, $boundary
}

function Send-MailgunEmail() {
    <#
        .SYNOPSIS
            Sends an email through mailguns API
    #>
    param(
        # The From e-mail address
        [Parameter(Mandatory = $True)]
        [string] $from,
        # The To e-mail address (comma divided string)
        [Parameter(Mandatory = $True)]
        [array] $to,
        # The bcc e-mail adresses
        [Parameter(Mandatory = $False)]
        [array] $bcc,
        # the subject
        [Parameter(Mandatory = $False)]
        [string] $subject = 'Mail without subject',
        # the text in the Text part
        [Parameter(Mandatory = $False)]
        [string] $text = 'Mail does not support Non Html readers',
        # the text in the HTML part
        [Parameter(Mandatory = $False)]
        [string] $htmlText = '<html>no body content</html>',
        # Either pass as parameter or set in MailGun.psd1
        [Parameter(Mandatory = $False)]
        [string] $emaildomain = $ModuleData.PrivateData.mailgun_emaildomain,
        # the api key as found in the mailgun profile either pass or set in MailGun.psd1
        [Parameter(Mandatory = $False)]
        [string] $apikey = $ModuleData.PrivateData.mailgun_apikey,
        # a list of attachments
        [Parameter(Mandatory = $False)]
        [hashtable] $attachments
    )

    $data = @{
        from    = $from
        to      = $to -join ','
        subject = $subject
        text    = $text
        html    = "<html>$htmlText</html>"
    }
    if ($bcc) { $data.Add('bcc', [string]($bcc -join ',')) }
    if ($attachments) {
        foreach ($attachment in $attachments.GetEnumerator()) {
            $attachmentbytes = [IO.File]::ReadAllBytes($attachment.Value)
            $data.Add($attachment.Name, $attachmentbytes)
        }
    }

    $url = "https://api.mailgun.net/v3/$($emaildomain)/messages"
    $headers = @{Authorization = "Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("api:$($apikey)"))}
    $boundary = [guid]::NewGuid().ToString()
    $contenttype = "multipart/form-data; boundary=$boundary"
    $body = ConvertTo-MimeMultiPartBody -Boundary $boundary -Data $data

    return Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body -ContentType $contenttype
}

Export-ModuleMember -Function Send-MailgunEmail
