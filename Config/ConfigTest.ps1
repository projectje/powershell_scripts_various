
Import-Module "$PSScriptRoot\Config.psm1" -Force

$config = Get-Config -path "$PSScriptRoot\config.cfg"
$config | Format-List

$config.GetType()

 $config | Get-Member -MemberType Property, NoteProperty | ForEach-Object {
    $_.Name
    $config.($_.Name)
 }
