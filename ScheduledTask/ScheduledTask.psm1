<#
    .SYNOPSIS
        Schedules a Task in Windows Task Scheduler, removes existing tasks
    .EXAMPLE
        $removetaskkeywords = @{ prerun = ''}
        Remove-ScheduledTaskByKeyword -task_keywords $removetaskkeywords
        $script='c:\temp\mypowershellscript.ps1'
        New-TaskInScheduler -executetask 'wscript' -executeparameters "`"$PSScriptRoot\prerun.vbs`" `"$script`"" -taskname "MyTask" -taskdescription "Cool Task" -taskpath "mytasks" -minutes 5
        Get-ScheduledTasks -path c:\temp\tasks.txt
#>

function Remove-ScheduledTaskByKeyword
{
    # keyword to search in (executable, arguments) for removing existing tasks
    param (
        [Parameter(Mandatory = $false)]
        [hashtable]
        $task_keywords
    )
    <#
        remove existing or older scheduled tasks
    #>
    $tasks = Get-ScheduledTask
    foreach($task in $tasks) {
        $taskexec = $task.actions.Execute -replace '.*\\'
        $taskarguments = $task.actions.Arguments
        $taskname = $task.TaskName
        foreach($key in $task_keywords.Keys) {
            if ($task_keywords[$key] -eq '') {
                if ($taskexec.ToLower() -like ('*'+$key+'*')) {
                    Unregister-ScheduledTask -TaskName $taskname -Confirm:$false
                }
            } else {
                if ($taskexec.ToLower() -like  ('*'+$key+'*') -and $taskarguments.ToLower() -like  ('*'+$task_keywords[$key]+'*')) {
                    Unregister-ScheduledTask -TaskName $taskname -Confirm:$false
                }
            }

        }
    }
}

function New-TaskInScheduler
{
    #
    # Create a task that runs every N minutes forever
    #
    param (
        # the executable to run
        [Parameter(Mandatory = $true)]
        [string]
        $executetask,
        # the exec parameters
        [Parameter(Mandatory = $true)]
        [string]
        $executeparameters,
        # the taskname
        [Parameter(Mandatory = $false)]
        [string]
        $taskname = 'newtask',
        # the task description
        [Parameter(Mandatory = $false)]
        [string]
        $taskdescription = 'New Task',
        # the task path
        [Parameter(Mandatory = $false)]
        [string]
        $taskpath = 'MyTasks',
        # every N minutes
        [Parameter(Mandatory = $false)]
        [int]
        $minutes = 5
    )

    $a1 = New-ScheduledTaskAction -Execute $executetask -Argument ($executeparameters)
    $t1 = New-ScheduledTaskTrigger -Daily -At 01:00
    $t2 = New-ScheduledTaskTrigger -Once -RepetitionInterval (New-TimeSpan -Minutes $minutes) -RepetitionDuration (New-TimeSpan -Hours 23 -Minutes 55) -At 01:00
    $t1.Repetition = $t2.Repetition
    $s1 = New-ScheduledTaskSettingsSet -Hidden -ExecutionTimeLimit (New-TimeSpan -Hours 1)
    Register-ScheduledTask -Trigger $t1 -Action $a1 -TaskName $taskname -Description $taskdescription -TaskPath $taskpath -Settings $s1 -RunLevel Highest
    #New-ScheduledTask -Trigger $t1 -Action $a1 -TaskName $taskname -Description $taskdescription
}

function Get-ScheduledTasks
{
    param (
        # path to export text file
        [Parameter(Mandatory = $true)]
        [string]
        $path
    )
    get-scheduledtask | Out-file  $path
}