# Rebuild the print master on Windows. All positions are in final-image pixels.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$page = [Drawing.Bitmap]::new(1024, 1024, [Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [Drawing.Graphics]::FromImage($page)
$g.SmoothingMode = 'AntiAlias'
$g.InterpolationMode = 'HighQualityBicubic'
$g.TextRenderingHint = 'AntiAliasGridFit'
$paper = '#FBF4E6'
$ink = '#142F32'
$muted = '#455955'
$red = '#A63A26'
$gold = '#E7AA45'
function Color($value) { [Drawing.ColorTranslator]::FromHtml($value) }
function Rect($color, $x, $y, $w, $h) {
    $brush = [Drawing.SolidBrush]::new((Color $color))
    $g.FillRectangle($brush, [single]$x, [single]$y, [single]$w, [single]$h)
    $brush.Dispose()
}
function Line($color, $width, $x, $y, $x2, $y2) {
    $pen = [Drawing.Pen]::new((Color $color), $width)
    $g.DrawLine($pen, [single]$x, [single]$y, [single]$x2, [single]$y2)
    $pen.Dispose()
}
function Poly($color, [float[]]$coords) {
    $points = for ($i=0; $i -lt $coords.Length; $i+=2) {
        [Drawing.PointF]::new($coords[$i], $coords[$i+1])
    }
    $brush = [Drawing.SolidBrush]::new((Color $color))
    $g.FillPolygon($brush, [Drawing.PointF[]]$points)
    $brush.Dispose()
}
function Disc($color, $x, $y, $r) {
    $brush = [Drawing.SolidBrush]::new((Color $color))
    $g.FillEllipse($brush, [single]($x-$r), [single]($y-$r), [single](2*$r), [single](2*$r))
    $brush.Dispose()
}
function TypeLine($value, $face, $size, $style, $color, $x, $y, $maxWidth) {
    $font = [Drawing.Font]::new($face, [single]$size, [Drawing.FontStyle]$style, 'Pixel')
    $brush = [Drawing.SolidBrush]::new((Color $color))
    $format = [Drawing.StringFormat]::GenericTypographic
    $width = $g.MeasureString($value, $font, 4096, $format).Width
    if ($width -gt $maxWidth) { throw "Line too wide ($width > $maxWidth): $value" }
    $g.DrawString($value, $font, $brush, [Drawing.PointF]::new($x,$y), $format)
    $format.Dispose()
    $brush.Dispose()
    $font.Dispose()
}
function Lines($values, $face, $size, $style, $color, $x, $y, $leading, $maxWidth) {
    foreach ($value in $values) {
        TypeLine $value $face $size $style $color $x $y $maxWidth
        $y += $leading
    }
}

# Each spot illustration uses a local 300 x 116 frame.
function DrawDymer {
    Rect '#D3DED5' 0 0 300 116
    Disc '#F8EBCF' 246 31 21
    Poly '#789589' @(0,96, 25,76, 57,79, 77,64, 121,83, 158,62, 206,76, 245,54, 300,74, 300,116, 0,116)
    Poly $ink @(20,16, 106,16, 110,27, 103,31, 115,40, 107,43, 120,55, 115,66, 126,69, 120,82, 133,107, 20,107)
    for ($row=0; $row -lt 5; $row++) {
        for ($col=0; $col -lt 4; $col++) {
            Rect '#DDC9A3' (28+19*$col) (23+16*$row) 10 9
        }
    }
    Poly '#315455' @(141,62, 151,57, 146,49, 156,40, 155,32, 165,28, 161,18, 197,18, 197,106, 137,106)
    for ($row=0; $row -lt 5; $row++) { Rect '#DDC9A3' 173 (24+16*$row) 13 9 }
    Poly $ink @(0,107, 58,103, 89,107, 118,88, 129,92, 135,81, 161,99, 189,99, 204,108, 250,102, 300,106, 300,116, 0,116)
    Line '#F4D7AA' 3 231 96 247 103
    foreach ($x in @(216,241)) {
        Disc $ink $x 80 5
        Rect $gold ($x-6) 77 13 3
        Poly $red @(($x-4),86, ($x+4),86, ($x+8),97, ($x+3),99, ($x+3),108, ($x-1),108, ($x-2),98, ($x-6),105, ($x-9),103)
        Rect '#F1D08F' ($x-4) 92 10 2
    }
}
function DrawBallot {
    Rect '#ECD9B1' 0 0 300 116
    # The harbour skyline sits behind the ballot, including triangular bracing.
    Rect '#ACAD8B' 0 89 300 27
    foreach ($b in @(@(0,65,15),@(17,75,16),@(35,55,15),@(52,65,12),@(68,40,17),@(89,69,17),@(226,65,18),@(247,45,19),@(270,62,12),@(285,73,15))) {
        Rect '#9BA790' $b[0] $b[1] $b[2] (108-$b[1])
    }
    Poly '#829583' @(48,108,48,42,61,25,70,45,70,108)
    Line '#E3D9B6' 2 50 46 67 70
    Line '#E3D9B6' 2 67 70 51 95
    Poly $ink @(90,75, 151,57, 218,70, 158,90)
    Poly '#3B6662' @(90,78, 157,94, 157,116, 90,116)
    Poly '#234344' @(161,93, 218,74, 218,116, 161,116)
    Line '#DFBC7E' 3 124 72 174 81
    Poly $red @(127,4, 179,17, 163,73, 111,60)
    Poly '#FCEDCC' @(131,9, 174,20, 160,67, 117,56)
    Line $ink 4 134 36 140 46
    Line $ink 4 140 46 158 28
}
function DrawRace {
    Rect '#233E40' 0 0 300 116
    for ($row=0; $row -lt 3; $row++) {
        for ($col=0; $col -lt 7; $col++) {
            if (($row+$col)%2 -eq 0) { Rect '#84958A' (222+12*$col) (4+12*$row) 12 12 }
        }
    }
    foreach ($b in @(@(8,48,18),@(31,36,9),@(45,43,27),@(83,28,12),@(104,48,34),@(146,33,14),@(165,44,23),@(195,32,13))) {
        Rect '#395755' $b[0] $b[1] $b[2] (60-$b[1])
    }
    Line $gold 2 0 62 78 62
    Line '#9DAD9F' 1 8 70 52 70
    Poly '#D45B39' @(38,58, 62,58, 69,75, 111,68, 135,46, 146,46, 158,62, 180,65, 199,73, 253,80, 267,77, 271,85, 252,90, 105,91, 72,85, 47,81)
    Poly '#F1C16A' @(86,80, 131,60, 149,61, 157,66, 128,68, 108,82)
    Disc $gold 162 60 7
    Line $ink 3 163 60 169 60
    foreach ($x in @(74,215)) {
        Disc '#11292B' $x 83 17
        Disc '#7C8D83' $x 83 10
        Disc '#243C3D' $x 83 6
    }
    Line '#506C66' 2 14 101 276 101
    Line $gold 2 134 108 299 108
}

$g.Clear((Color $paper))
Rect $red 32 28 10 65
TypeLine 'World Dispatch' 'Georgia' 68 Bold $ink 54 17 675
TypeLine 'SUNDAY' 'Arial' 17 Bold $red 762 34 216
TypeLine '22 November 2026' 'Arial' 25 Bold $ink 762 57 239
Rect $ink 32 111 960 4
Rect $ink 32 120 960 1

$hero = [Drawing.Image]::FromFile((Join-Path $PSScriptRoot 'antalya.png'))
$g.DrawImage($hero, [Drawing.Rectangle]::new(531,144,461,461))
$hero.Dispose()
TypeLine 'ANTALYA  /  CLIMATE' 'Arial' 21 Bold $red 33 151 480
Lines @('COP31 draft','leaves fossil','fuels unnamed') 'Georgia' 61 Bold $ink 31 204 67 495
Rect $red 34 434 65 5
Lines @('Talks stretched into Sunday as nearly','200 delegations sought agreement','on energy and climate finance.') 'Arial' 25 Regular $ink 33 465 33 486

Rect $ink 32 627 960 3
$stories = @(
    @{ X=32; Art='DrawDymer'; Place='DYMER  /  UKRAINE'; Head=@('Rescuers search','a shattered block'); Body=@('A Russian drone hit a','five-story apartment building','in the Kyiv region.') },
    @{ X=362; Art='DrawBallot'; Place='HONG KONG  /  POLITICS'; Head=@('856 candidates,','723 seats'); Body=@('Voters cast ballots in 31','contested Election Committee','subsectors.') },
    @{ X=692; Art='DrawRace'; Place='LAS VEGAS  /  FORMULA 1'; Head=@('Verstappen wins','by 0.639 seconds'); Body=@('Lando Norris finished second','and Oscar Piastri third for','McLaren.') }
)
foreach ($story in $stories) {
    $x = $story.X
    TypeLine $story.Place 'Arial' 17 Bold $red $x 648 300
    $state = $g.Save()
    $g.TranslateTransform($x,681)
    $g.SetClip([Drawing.Rectangle]::new(0,0,300,116))
    & $story.Art
    $g.Restore($state)
    Lines $story.Head 'Georgia' 32 Bold $ink $x 809 37 303
    Lines $story.Body 'Arial' 21 Regular $muted $x 897 26 302
}
Line '#B6B6A4' 1 347 649 347 975
Line '#B6B6A4' 1 677 649 677 975
Rect $ink 32 991 960 3
$page.Save((Join-Path $PSScriptRoot 'front-page.png'), [Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$page.Dispose()
