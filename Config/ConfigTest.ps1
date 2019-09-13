
 Import-Module "$PSScriptRoot\Config.psm1" -Force

 $config = Get-Config -path "$PSScriptRoot\config.cfg"
 $config | Format-List
 