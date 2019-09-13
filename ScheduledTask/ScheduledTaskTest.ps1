Import-Module "$PSScriptRoot\ScheduledTask.psm1" -Force

$removetaskkeywords = @{ prerun = ''}
Remove-ScheduledTaskByKeyword -task_keywords $removetaskkeywords
$script='c:\temp\mypowershellscript.ps1'
New-TaskInScheduler -executetask 'wscript' -executeparameters "`"$PSScriptRoot\prerun.vbs`" `"$script`"" -taskname "MyTask" -taskdescription "Cool Task" -taskpath "mytasks" -minutes 5
Get-ScheduledTasks -path c:\temp\tasks.txt

