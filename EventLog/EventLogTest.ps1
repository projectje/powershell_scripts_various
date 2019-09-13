Import-Module "$PSScriptRoot\EventLog.psm1" -Force
#
# Requires Administrator Rights: self elevate
#
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}
#
$source = "SpecificApplicationName"
$msg1 = "ERROR FOUND - ACTION AA"
$msg2 = "MULTIPLE ERRORS - ACTION BB"
for ($i=0; $i -lt 7; $i++) {
    Write-EventLogEvent -Source $source -message $msg1
    $shouldact = Assert-ShouldActOnEventLogEvent -msg1 $msg1 -msg2 $msg2 -amountofmsg1 5 -amountOfHours 2
    if ($shouldact -eq 1) {
        write-host "yes reboot is needed log this"
        Write-EventLogEvent -Source $source -message $msg2
    } elseif ($shouldact -eq 0) {
        write-host "no reboot is needed"
    } elseif ($shouldact -eq 2) {
        write-host "even the reboot did not work. Panic!"
    }
}
