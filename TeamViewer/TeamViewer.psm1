<#
    .SYNOPSIS
        for starters return a teamviewer url
#>

function GetTeamViewerDetails() {
    <#
        Regkey for machines in my scope
    #>
    $regkey = Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\TeamViewer -ErrorAction SilentlyContinue
    if ($regkey) {
       $clientid = $regkey.ClientID
    }
    $url = 'https://start.teamviewer.com/' + $clientid
    return $url
}