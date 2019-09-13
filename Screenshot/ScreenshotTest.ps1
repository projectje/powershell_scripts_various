Import-Module "$PSScriptRoot\Screenshot.psm1" -Force

$pixels = New-ScreenShot -rectangle_width 1000 -rectangle_height 900
Assert-PixelColorPercentage -pixels $pixels -colors 'ff000000'
$changed = Assert-PixelChangeOnScreen -seconds 5
$notchanged = Assert-PixelChangeOnScreenOnePixel -seconds 5 -amountOfColors 2
if ($null -ne $notchanged) {
    $notchanged | ForEach-Object { write-host $notchanged.Name}
}
