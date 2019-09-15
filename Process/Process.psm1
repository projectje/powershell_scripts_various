<#
    .SYNOPSIS
        Get Process and if not running or stalled close and restart
#>

function Get-ProcessRestartIfDownOrFrozen {
    # gets a process and if not running restart
    param (
        [Parameter(Mandatory = $True)]
        [string]
        $process_name,
        [Parameter(Mandatory = $True)]
        [string]
        $process_path,
        [Parameter(Mandatory = $True)]
        [bool]
        $restart_process
    )
    $process = Get-Process -Name $process_name -ErrorAction Ignore
    if (!$process)
    {
        if ($restart_process) {
            # no $p.MainModule.FileName since there is no process
            & $process_path
            Start-Sleep -Seconds 5
            return 2, $null, $null
        } else {
            return 0, 0, $false
        }
    }
    else
    {
        $responding = $process | Get-Member Responding
        if(!$responding) {
            # this is unreliable unless you have a specific application
            return 1, $process[0].Id, $false
        }
        return 1, $process[0].Id, $true
    }
}

function Get-ProcessInfoInHtml
{
    param (
        [Parameter(Mandatory = $True)]
        [int] $process_id
    )

    $process = Get-Process -Id $process_id
    if ($process) {
        $vinfo = Get-Process -Id $process.Id -FileVersionInfo
        $file_info_html_part = $vinfo | ConvertTo-Html -As list -Fragment -PreContent '<h2>File Information</h2>'
        $process_info_html_part = $process | ConvertTo-Html -As list -Fragment -PreContent '<h2>Process Information</h2>'
        return $file_info_html_part + $process_info_html_part
    }
}
