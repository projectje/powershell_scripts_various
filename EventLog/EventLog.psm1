<#
    .SYNOPSIS
        Writes or Reads certain specific event to Event Log
    .EXAMPLE
        Log-Event -Source $source -message $msg
#>
Function Write-EventLogEvent {
    <#
        .SYNOPSIS
            Logs an Event with some default parameters
    #>
    param (
        # Name of the Log
        [Parameter(Mandatory = $false)]
        [string]
        $LogName = "Application",
        # Source that is used
        [Parameter(Mandatory = $false)]
        [string]
        $Source = "Check",
        # Type of Event Information, Error or Warning
        [Parameter(Mandatory = $false)]
        [string]
        $Type = "E",
        [int]
        [Parameter(Mandatory = $false)]
        $eventID = 33,
        [string]
        $message = ''
    )
    switch($Type.ToUpper()) {
        "I"{ $ET = "Information"}
        "E" { $ET = "Error"}
        "W" { $ET = "Warning"}
        else { $ET = $type}
    }
    $eventScriptBlock = {Write-EventLog -LogName $logName -Source $Source -EntryType $ET -Message $message -EventId $eventID -ErrorAction STOP}
    try { & $eventScriptBlock  }
    catch {
        New-EventLog -LogName $logName -Source $Source
        & $eventScriptBlock
    }
}

function Assert-ShouldActOnEventLogEvent {
    <#
        .SYNOPSIS
            Checks the event log for an event after a certain time e.g. past 2 hours after midnight and if found a certain number returns true
            (to act upon). E.g. if 5 times a certain event was logged in the past 2 hours act upon it
            Returns true if a resolving action has to be taken
    #>
    param (
        # Log defaults to Application
        [Parameter(Mandatory = $false)]
        [string]
        $application = 'Application',
        # the (error) message to check against
        [Parameter(Mandatory = $false)]
        [string]
        $msg1,
        # the amount of (error) messages
        [Parameter(Mandatory = $false)]
        [int]
        $amountofmsg1 = 1,
        # the message that indicates a resolving action has taken place
        [Parameter(Mandatory = $false)]
        [string]
        $msg2,
        # the amount of hours to look in the past for messages
        [Parameter(Mandatory = $false)]
        [int]
        $amountOfHours = 2
    )
    # get all events after midnight
    $after = Get-Date -Hour "00" -Minute "00" -Second "00"
    $results = Get-EventLog -message $msg1 -LogName $application -After $after -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    # if we found more than N error messages:
    if ($results.Count -gt $amountofmsg1)
    {
        # if a resolving action already has taken place the past N hours then do no resolving action
        $currentDate = Get-Date
        $hour_target = $currentDate.Hour - $amountOfHours
        if ($hour_target -lt 0) {
            $hour_target = 0
        }
        $after = Get-Date -Hour $hour_target
        $results = Get-EventLog -message $msg2 -LogName $application -After $after -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        if ($results.Count -lt 1) {
            return 1
        }
        else
        {
            # in the case even the resolving action did not work
            return 2
        }
    }
    else
    {
        return 0
    }
}