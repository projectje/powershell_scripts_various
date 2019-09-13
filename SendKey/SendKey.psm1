<#
    .SYNOPSIS
        send a keypress to a certain application
        see: https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.sendkeys?view=netframework-4.8 for keys
        see: https://stackoverflow.com/questions/4993926/maximize-window-and-bring-it-in-front-with-powershell
#>

function Send-KeyPress{
    param(
        # The key combination
        [Parameter(Mandatory = $True)]
        [string]
        $keypress,

        # The process to search for , only support processes with 1 entry
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $processname
    )

    $app_process = Get-Process -Name $processname -ErrorAction Ignore
    if ($app_process -and $app_process.GetType().BaseType.toString() -ne 'System.Array') {
        $sig = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
        $sig2 = '[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);'
        Add-Type -MemberDefinition $sig -name ShowWindowAsyncCall -namespace Win32
        Add-Type -MemberDefinition $sig2 -name SetForegroundWindowCall -namespace Win32
        $hwnd = @(Get-Process -Name $processname)[0].MainWindowHandle
        [Win32.ShowWindowAsyncCall]::ShowWindowAsync($hwnd, 3)  | Out-Null
        [Win32.SetForegroundWindowCall]::SetForegroundWindow($hwnd) | Out-Null
        [System.Windows.Forms.SendKeys]::SendWait($keypress)
    }
}