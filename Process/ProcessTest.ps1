Import-Module "$PSScriptRoot\Process.psm1" -Force

$p = Get-ProcessRestartIfDownOrFrozen -process_name TotalCmd64 -process_path 'C:\Apps\totalcmd\TOTALCMD64.EXE' -restart_process $true
if ($p[0] -eq 1) {
    Get-ProcessInfoInHtml -process_id $p[1]
}
if ($p[0] -eq 2) {
    $p2 = Get-ProcessRestartIfDownOrFrozen -process_name TotalCmd64 -process_path 'C:\Apps\totalcmd\TOTALCMD64.EXE' -restart_process $true
    if ($p2 -eq 1) {
        Get-ProcessInfoInHtml -process_id $p2[1]
    }
}
if ($p[0] -eq 3)
{
    write-host "down"
}
