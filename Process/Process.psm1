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
            try {
               & $process_path
            } catch  {
                return 4, 0, $false
            }
            Start-Sleep -Seconds 5
            return 2, $null, $null
        } else {
            return 3, 0, $false
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

function Get-ProcessRunningStatus {
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
    $result = @{}
    $p = Get-ProcessRestartIfDownOrFrozen -process_name $process_name -process_path $process_path -restart_process $restart_process
    if ($p[0] -eq 1) {
        if ($p[2] -eq $false)
        {
            $result["status"] ="process is not responsive"
            $result["description"] = Get-ProcessInfoInHtml -process_id $p[1]
        }
        else
        {
            $result["status"] ="ok"
            $result["description"] = Get-ProcessInfoInHtml -process_id $p[1]
        }
    }
    elseif ($p[0] -eq 2) {
        $p2 = Get-ProcessRestartIfDownOrFrozen -process_name $process_name -process_path $process_path -restart_process $restart_process
        if ($p2 -eq 1) {
            $result["status"] ="restarted process"
            $result["description"] = Get-ProcessInfoInHtml -process_id $p2[1]
        } else {
            $result["status"] ="tried restarting process but could not restart"
            $result["description"] =""
        }
    }
    elseif ($p[0] -eq 3)
    {
        $result["status"] ="process not running"
        $result["description"] = "process not running and not configured to auto restart"
    }
    elseif ($p[0] -eq 4)
    {
        $result["status"] ="process not running"
        $result["description"] = "process not running and no executable installed"
    }

    return $result
}