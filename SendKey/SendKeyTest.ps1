Import-Module "$PSScriptRoot\SendKey.psm1" -Force

Send-KeyPress -processname "TotalCMD64" -keypress "^{A}"
