<#
    .SYNOPSIS
        Makes a screenshot and save to file or check if screen contains certain details
    .EXAMPLE
        $pixels = New-ScreenShot -rectangle_width 1000 -rectangle_height 900
        Assert-PixelColorPercentage -pixels $pixels -colors 'ff000000'
        $changed = Assert-PixelChangeOnScreen -seconds 5
        $changed = Assert-PixelChangeOnScreenOnePixel -seconds 5 -amountOfColors 2
#>
function New-ScreenShot
{
    #
    # Makes a screenshot, optional saves to temp dir as GUID.jpg and returns pixels array of unique pixels found
    #
    param (
        # Whether we make a copy to disk or not
        [Parameter(Mandatory = $False)]
        [bool]
        $write = $false,
        # The folder location of the screenshot
        [Parameter(Mandatory = $False)]
        [string]
        $path = 'c:\temp\',
        # start rectangle X
        [Parameter(Mandatory = $False)]
        [int]
        $rectangle_x = 0,
        # start rectangle Y
        [Parameter(Mandatory = $False)]
        [int]
        $rectangle_y = 0,
        # rectangle width
        [Parameter(Mandatory = $False)]
        [int]
        $rectangle_width = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width,
        # rectangle height
        [Parameter(Mandatory = $False)]
        [int]
        $rectangle_height = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
    )
    [Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    $bounds = [Drawing.Rectangle]::FromLTRB($rectangle_x, $rectangle_y, $rectangle_width, $rectangle_height)

    function screenshot([Drawing.Rectangle]$bounds) {
        $table = @{}
        $BitMap = New-Object Drawing.Bitmap $bounds.width, $bounds.height
        $graphics = [Drawing.Graphics]::FromImage($BitMap)
        $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
        foreach($h in 1..$BitMap.Height) {
            foreach($w in 1..$BitMap.Width) {
                $table[$BitMap.GetPixel($w - 1,$h - 1)] = $true
            }
        }
        if ($write -eq $true) {
            $BitMap.Save($path + [GUID]::NewGuid() + ".jpg")
        }

        $graphics.Dispose()
        $BitMap.Dispose()
        return $table.Keys
    }
    return screenshot $bounds
}

function Assert-PixelColorPercentage
{
    #
    # Checks the percentage of a certain set of pixel colors e.g. Assert-PixelColorPercentage -pixels $pixels -colors 'ff000000'
    #
    param (
        # an array of pixel objects, if not passed will make screenshot
        [Parameter(Mandatory = $false)]
        [array]
        $pixels,
        # Test for an array of hex colors e.g. $colors = 'ffa4a4a6', 'ffa4a5a6'
        [Parameter(Mandatory = $true)]
        [array]
        $colors
    )

    # if no array is passed make screenshot
    if (!$pixels -or ($null -eq $pixels)) {
        $pixels = New-Screenshot
    }

    $colorCounter = 0
    for($i=0; $i -lt $pixels.Count; $i++) {
        if ($colors | Where-Object {$_ -eq $pixels[$i].Name}) {
            write-host $pixels[$i].Name
            $colorCounter++
        }
    }
    return ($colorCounter / $pixels.Count)*100
}

function Assert-PixelChangeOnScreen
{
    #
    # Checks the difference between 2 moments and returns the color differences
    #
    param (
        # amount of seconds to wait
        [Parameter(Mandatory = $false)]
        [double]
        $seconds = 10,
        # amount pixels max otherwise return (to prevent processing time)
        [Parameter(Mandatory = $false)]
        [double]
        $amountOfColors = 1000
    )

    $colors = New-Screenshot
    Start-Sleep -s $seconds
    $colors2 = New-ScreenShot

    if (($colors.Count -gt $amountOfColors) -or ($colors2.Count -gt $amountOfColors)) {
        return $null
    }

    # colors that were present but no longer are present
    $i = 0
    $difference = @{}
    foreach($color in $colors) {
        $found = $false
        foreach($color2 in $colors2) {
            if ($color.Name -eq $color2.Name) {
                $found = $true
                break
            }
        }
        if ($found -eq $false) {
            $difference.Add($i++,$color.Name)
        }
    }
    # colors that are new
    $i = 0
    $difference2 = @{}
    foreach($color2 in $colors2) {
        $found = $false
        foreach($color in $colors) {
            if ($color2.Name -eq $color.Name) {
                $found = $true
                break
            }
        }
        if ($found -eq $false) {
            $difference2.Add($i++,$color2.Name)
        }
    }

    return $difference, $difference2, $colors, $colors2
}

function Assert-PixelChangeOnScreenOnePixel
{
    #
    # Checks the difference between 2 moments and returns unchanged set if no difference AND less than N pixel color only
    # $null = the screen changed - e.g. to check for frozen screens
    param (
        # amount of seconds to wait
        [Parameter(Mandatory = $false)]
        [double]
        $seconds = 10,
        # amount pixels max
        [Parameter(Mandatory = $false)]
        [double]
        $amountOfColors = 2
    )
    $changed = Assert-PixelChangeOnScreen -seconds $seconds -amountOfColors $amountOfColors
    if ($null -ne $changed) {
        if (($changed[0].Count -eq 0) -and ($changed[1].Count -eq 0) -and ($changed[2].Count -le 2)) {
            return $changed[2]
        }
    }
    return $null
}

Export-ModuleMember -Function New-ScreenShot, Assert-PixelColorPercentage, Assert-PixelChangeOnScreen, Assert-PixelChangeOnScreenOnePixel