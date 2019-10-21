Import-Module "$PSScriptRoot\Process.psm1" -Force

Get-ProcessRunningStatus -process_name TotalCmd64 -process_path 'C:\Apps\totalcmd\TOTALCMD64.EXE' -restart_process $true
