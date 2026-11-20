# Google Play phone screenshots, 1080x1920 (9:16).
# Raw captures are 720x1600, which Play rejects (long side must be at most 2x the short side).
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$srcDir = 'c:\good\github2026\ludosumbarta\assets'
$outDir = Join-Path $srcDir 'play-console'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
Get-ChildItem $outDir -Filter '*.jpg' | Remove-Item -Force
$probe = Join-Path $outDir '_probe'
if (Test-Path $probe) { Remove-Item $probe -Recurse -Force }

function Add-RoundRect {
    param($path, [single]$x, [single]$y, [single]$w, [single]$h, [single]$r)
    $d = [single]([Math]::Min($r * 2, [Math]::Min($w, $h)))
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
    $path.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
    $path.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
    [void]$path.CloseFigure()
}

function Draw-Diamond {
    param($g, $brush, $pen, [single]$cx, [single]$cy, [single]$r)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddLine($cx, ($cy - $r), ($cx + $r), $cy)
    $path.AddLine(($cx + $r), $cy, $cx, ($cy + $r))
    $path.AddLine($cx, ($cy + $r), ($cx - $r), $cy)
    $path.CloseFigure()
    if ($brush) { $g.FillPath($brush, $path) }
    if ($pen) { $g.DrawPath($pen, $path) }
    $path.Dispose()
}

function Draw-TrackedCenter {
    param($g, [string]$text, $font, $brush, [single]$centerX, [single]$y, [single]$tracking)
    $fmt = [System.Drawing.StringFormat]::GenericTypographic
    $fmt.FormatFlags = [System.Drawing.StringFormatFlags]::MeasureTrailingSpaces
    $widths = @()
    $total = [single]0
    foreach ($ch in $text.ToCharArray()) {
        $w = [single]$g.MeasureString([string]$ch, $font, 1000, $fmt).Width
        $widths += $w
        $total += $w
    }
    if ($text.Length -gt 1) { $total += $tracking * ($text.Length - 1) }
    $x = $centerX - ($total / 2)
    for ($i = 0; $i -lt $text.Length; $i++) {
        $g.DrawString([string]$text[$i], $font, $brush, $x, $y, $fmt)
        $x += $widths[$i] + $tracking
    }
    $fmt.Dispose()
}

function Hide-TestButton {
    param($bmp)
    # Cover the orange "Test: Launch" debug control with the header cream beside it.
    for ($y = 84; $y -le 158; $y++) {
        $ref = $bmp.GetPixel(468, $y)
        for ($x = 570; $x -le 706; $x++) {
            $bmp.SetPixel($x, $y, $ref)
        }
    }
}

function Save-Jpeg {
    param($bmp, $path, [int]$quality)
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
        Where-Object { $_.MimeType -eq 'image/jpeg' }
    $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, [int64]$quality)
    $bmp.Save($path, $codec, $ep)
    $ep.Dispose()
}

# Headlines follow the River Oath chapters: the rope, the royal game,
# Vardhana, the ancient road, Takshak, the neon road, the fort, the table.
# Full-body visitor sketches stand beside the phone on every card.
$shots = @(
    @{
        file       = 'Screenshot_20261023_173105_Ludo Sumbarta.jpg'
        out        = '01-the-rope.jpg'
        title      = 'THE ROPE'
        sub        = 'Six walkers. One wooden die.'
        glow       = @(186, 120, 48)
        mask       = $false
        sketch     = 'fort_visitor_sketch_borin.webp'
        walker     = 'BORIN GUBATTI'
        sketchSide = 'left'
    },
    @{
        file       = 'Screenshot_20261025_183656_Ludo Sumbarta.jpg'
        out        = '02-the-royal-game.jpg'
        title      = 'THE ROYAL GAME'
        sub        = 'Win the board at every gate.'
        glow       = @(46, 120, 72)
        mask       = $false
        sketch     = 'fort_visitor_sketch_maya.webp'
        walker     = 'MAYA MERSACE'
        sketchSide = 'right'
    },
    @{
        file       = 'Screenshot_20261025_183712_Ludo Sumbarta.jpg'
        out        = '03-meadow-gateway.jpg'
        title      = 'MEADOW GATEWAY'
        sub        = 'The reed gate at Vardhana.'
        glow       = @(196, 140, 48)
        mask       = $true
        sketch     = 'fort_visitor_sketch_baby.webp'
        walker     = 'BABY DUFAAN'
        sketchSide = 'left'
    },
    @{
        file       = 'Screenshot_20261025_183609_Ludo Sumbarta.jpg'
        out        = '04-ancient-road.jpg'
        title      = 'ANCIENT ROAD'
        sub        = 'Ten gates, from meadow to crown.'
        glow       = @(42, 130, 64)
        mask       = $false
        sketch     = 'fort_visitor_sketch_taro.webp'
        walker     = 'TARO DOMIZON'
        sketchSide = 'right'
    },
    @{
        file       = 'Screenshot_20261025_183739_Ludo Sumbarta.jpg'
        out        = '05-king-of-serpents.jpg'
        title      = 'KING OF SERPENTS'
        sub        = 'The ladders rise. Takshak waits.'
        glow       = @(196, 130, 42)
        mask       = $false
        sketch     = 'fort_visitor_sketch_kael.webp'
        walker     = 'KAEL GOBU'
        sketchSide = 'left'
    },
    @{
        file       = 'Screenshot_20261025_183614_Ludo Sumbarta.jpg'
        out        = '06-neon-dawn.jpg'
        title      = 'NEON DAWN'
        sub        = 'The same oath, recoded as light.'
        glow       = @(36, 150, 170)
        mask       = $false
        sketch     = 'fort_visitor_sketch_kael_techno.webp'
        walker     = 'KAEL GOBU'
        sketchSide = 'right'
    },
    @{
        file       = 'Screenshot_20261031_144301_Ludo Sumbarta.jpg'
        out        = '07-fort-sumbarta.jpg'
        title      = 'FORT SUMBARTA'
        sub        = 'Every hall in the fort is a game.'
        glow       = @(186, 120, 48)
        mask       = $false
        sketch     = 'fort_visitor_sketch_mani.webp'
        walker     = 'MANI DUFAAN'
        sketchSide = 'left'
    },
    @{
        file       = 'Screenshot_20261025_183756_Ludo Sumbarta.jpg'
        out        = '08-the-fort-table.jpg'
        title      = 'THE FORT TABLE'
        sub        = 'Pocket the queen in the courtyard.'
        glow       = @(32, 140, 120)
        mask       = $false
        sketch     = 'fort_visitor_sketch_maya_techno.webp'
        walker     = 'MAYA MERSACE'
        sketchSide = 'right'
    }
)

$canvasW = 1080
$canvasH = 1920
$cropY = 64
$cropH = 1442
$cropW = 720

function Load-SketchBitmap {
    param([string]$webpName)
    $webpPath = Join-Path $outDir $webpName
    if (-not (Test-Path $webpPath)) {
        throw "Missing sketch: $webpPath"
    }
    $png = Join-Path $env:TEMP ("ludo-sketch-" + [IO.Path]::GetFileNameWithoutExtension($webpName) + ".png")
    # Hard-key near-pure black so dark clothes stay solid and fringes stay clean.
    & ffmpeg -y -loglevel error -i $webpPath `
        -vf "colorkey=0x000000:0.045:0.0,format=rgba" $png
    if ($LASTEXITCODE -ne 0) { throw "Could not convert sketch $webpName" }
    $raw = [System.Drawing.Bitmap]::FromFile($png)
    # Detached ARGB copy — clear to transparent first or black leaks into the matte.
    $bmp = New-Object System.Drawing.Bitmap $raw.Width, $raw.Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $cg = [System.Drawing.Graphics]::FromImage($bmp)
    $cg.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $cg.Clear([System.Drawing.Color]::Transparent)
    $cg.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $cg.DrawImage($raw, 0, 0, $raw.Width, $raw.Height)
    $cg.Dispose()
    $raw.Dispose()
    Remove-Item $png -ErrorAction SilentlyContinue
    return $bmp
}

$sketchCache = @{}
foreach ($shot in $shots) {
    if ($shot.sketch -and -not $sketchCache.ContainsKey($shot.sketch)) {
        $sketchCache[$shot.sketch] = Load-SketchBitmap $shot.sketch
        Write-Output ("loaded sketch  {0}" -f $shot.sketch)
    }
}

$titleFamily = (New-Object System.Drawing.FontFamily 'Palatino Linotype')
$kickerFont = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$subFont = New-Object System.Drawing.Font('Palatino Linotype', 30, [System.Drawing.FontStyle]::Italic, [System.Drawing.GraphicsUnit]::Pixel)

$gemColors = @(
    [System.Drawing.Color]::FromArgb(26, 122, 224),
    [System.Drawing.Color]::FromArgb(255, 211, 26),
    [System.Drawing.Color]::FromArgb(18, 179, 74),
    [System.Drawing.Color]::FromArgb(238, 48, 48)
)

foreach ($shot in $shots) {
    $srcPath = Join-Path $srcDir $shot.file
    $locked = [System.Drawing.Bitmap]::FromFile($srcPath)
    $game = New-Object System.Drawing.Bitmap $locked.Width, $locked.Height, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $gCopy = [System.Drawing.Graphics]::FromImage($game)
    $gCopy.DrawImage($locked, 0, 0, $locked.Width, $locked.Height)
    $gCopy.Dispose()
    $locked.Dispose()

    if ($shot.mask) { Hide-TestButton $game }

    $canvas = New-Object System.Drawing.Bitmap $canvasW, $canvasH, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

    # Soft echo of the capture, so each card takes its color from the game.
    $tinyW = 68
    $tinyH = [int]($tinyW * $game.Height / $game.Width)
    $tiny = New-Object System.Drawing.Bitmap $tinyW, $tinyH
    $gt = [System.Drawing.Graphics]::FromImage($tiny)
    $gt.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gt.DrawImage($game, 0, 0, $tinyW, $tinyH)
    $gt.Dispose()
    $coverScale = [Math]::Max($canvasW / $tinyW, $canvasH / $tinyH)
    $coverW = [single]($tinyW * $coverScale)
    $coverH = [single]($tinyH * $coverScale)
    $g.DrawImage($tiny, [single](($canvasW - $coverW) / 2), [single](($canvasH - $coverH) / 2), $coverW, $coverH)
    $tiny.Dispose()

    $washRect = New-Object System.Drawing.Rectangle 0, 0, $canvasW, $canvasH
    $wash = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $washRect,
        ([System.Drawing.Color]::FromArgb(236, 28, 8, 14)),
        ([System.Drawing.Color]::FromArgb(210, 8, 4, 8)),
        ([System.Drawing.Drawing2D.LinearGradientMode]::Vertical))
    $blend = New-Object System.Drawing.Drawing2D.ColorBlend(4)
    $blend.Colors = @(
        [System.Drawing.Color]::FromArgb(242, 22, 6, 12),
        [System.Drawing.Color]::FromArgb(206, 36, 10, 16),
        [System.Drawing.Color]::FromArgb(150, 18, 8, 12),
        [System.Drawing.Color]::FromArgb(214, 8, 4, 8)
    )
    $blend.Positions = @(0.0, 0.16, 0.46, 1.0)
    $wash.InterpolationColors = $blend
    $g.FillRectangle($wash, $washRect)
    $wash.Dispose()

    $lattice = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(28, 232, 196, 120)), 1
    for ($ly = 16; $ly -lt $canvasH; $ly += 36) {
        for ($lx = 16; $lx -lt $canvasW; $lx += 36) {
            $g.DrawLine($lattice, $lx, ($ly - 7), ($lx + 7), $ly)
            $g.DrawLine($lattice, ($lx + 7), $ly, $lx, ($ly + 7))
            $g.DrawLine($lattice, $lx, ($ly + 7), ($lx - 7), $ly)
            $g.DrawLine($lattice, ($lx - 7), $ly, $lx, ($ly - 7))
        }
    }
    $lattice.Dispose()

    $side = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle 0, 0, 180, $canvasH),
        ([System.Drawing.Color]::FromArgb(90, 6, 2, 4)),
        ([System.Drawing.Color]::FromArgb(0, 6, 2, 4)),
        ([System.Drawing.Drawing2D.LinearGradientMode]::Horizontal))
    $g.FillRectangle($side, 0, 0, 180, $canvasH)
    $side.Dispose()
    $g.TranslateTransform($canvasW, 0)
    $g.ScaleTransform(-1, 1)
    $sideR = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle 0, 0, 180, $canvasH),
        ([System.Drawing.Color]::FromArgb(90, 6, 2, 4)),
        ([System.Drawing.Color]::FromArgb(0, 6, 2, 4)),
        ([System.Drawing.Drawing2D.LinearGradientMode]::Horizontal))
    $g.FillRectangle($sideR, 0, 0, 180, $canvasH)
    $sideR.Dispose()
    $g.ResetTransform()

    $cornerPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(210, 214, 170, 78)), 2.25
    $cornerPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $cornerPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $inset = 26
    $arm = 46
    foreach ($pair in @(
            @($inset, $inset, 1, 1),
            @(($canvasW - $inset), $inset, -1, 1),
            @($inset, ($canvasH - $inset), 1, -1),
            @(($canvasW - $inset), ($canvasH - $inset), -1, -1)
        )) {
        $cx = [single]$pair[0]
        $cy = [single]$pair[1]
        $sx = [single]$pair[2]
        $sy = [single]$pair[3]
        $g.DrawLine($cornerPen, $cx, $cy, ($cx + $sx * $arm), $cy)
        $g.DrawLine($cornerPen, $cx, $cy, $cx, ($cy + $sy * $arm))
    }
    $cornerPen.Dispose()

    $centerFmt = New-Object System.Drawing.StringFormat
    $centerFmt.Alignment = [System.Drawing.StringAlignment]::Center
    $centerFmt.LineAlignment = [System.Drawing.StringAlignment]::Near

    $titleSize = [single]80
    $titleFont = New-Object System.Drawing.Font($titleFamily, $titleSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $measureFmt = [System.Drawing.StringFormat]::GenericTypographic
    while ($titleSize -gt 60) {
        $fitted = $g.MeasureString($shot.title, $titleFont, 4000, $measureFmt).Width
        if ($fitted -le 960) { break }
        $titleFont.Dispose()
        $titleSize -= 2
        $titleFont = New-Object System.Drawing.Font($titleFamily, $titleSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    }

    $kickerY = [single]36
    $kickerBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(236, 228, 196, 130))
    $kickerShadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(160, 0, 0, 0))
    Draw-TrackedCenter $g 'LUDO SUMBARTA' $kickerFont $kickerShadow ($canvasW / 2) ($kickerY + 2) 3.2
    Draw-TrackedCenter $g 'LUDO SUMBARTA' $kickerFont $kickerBrush ($canvasW / 2) $kickerY 3.2
    $kickerBrush.Dispose()
    $kickerShadow.Dispose()

    $titleTop = [single]68
    $titleRect = New-Object System.Drawing.RectangleF 40, $titleTop, ($canvasW - 80), ($titleSize + 16)
    $textPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $textPath.AddString(
        $shot.title,
        $titleFamily,
        [int][System.Drawing.FontStyle]::Bold,
        $titleSize,
        $titleRect,
        $centerFmt)

    $shadowPath = [System.Drawing.Drawing2D.GraphicsPath]$textPath.Clone()
    $shadowMatrix = New-Object System.Drawing.Drawing2D.Matrix
    $shadowMatrix.Translate(0, 6)
    $shadowPath.Transform($shadowMatrix)
    $shadowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(150, 42, 8, 16))
    $g.FillPath($shadowBrush, $shadowPath)
    $shadowBrush.Dispose()
    $shadowPath.Dispose()
    $shadowMatrix.Dispose()

    $goldBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $titleRect,
        ([System.Drawing.Color]::FromArgb(255, 246, 214)),
        ([System.Drawing.Color]::FromArgb(196, 138, 52)),
        ([System.Drawing.Drawing2D.LinearGradientMode]::Vertical))
    $goldBlend = New-Object System.Drawing.Drawing2D.ColorBlend(3)
    $goldBlend.Colors = @(
        [System.Drawing.Color]::FromArgb(255, 244, 206),
        [System.Drawing.Color]::FromArgb(244, 208, 120),
        [System.Drawing.Color]::FromArgb(186, 124, 42)
    )
    $goldBlend.Positions = @(0.0, 0.48, 1.0)
    $goldBrush.InterpolationColors = $goldBlend
    $g.FillPath($goldBrush, $textPath)
    $goldBrush.Dispose()
    $edgePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 92, 48, 12)), 1.25
    $g.DrawPath($edgePen, $textPath)
    $edgePen.Dispose()
    $gemY = [single]([Math]::Ceiling($textPath.GetBounds().Bottom) + 20)
    $textPath.Dispose()
    $rulePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(200, 214, 170, 78)), 1.5
    $rulePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $rulePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $gemSpan = 78
    $g.DrawLine($rulePen, 250, $gemY, (($canvasW / 2) - $gemSpan), $gemY)
    $g.DrawLine($rulePen, (($canvasW / 2) + $gemSpan), $gemY, ($canvasW - 250), $gemY)
    $rulePen.Dispose()
    $gemXs = @(-39, -13, 13, 39)
    for ($i = 0; $i -lt 4; $i++) {
        $gb = New-Object System.Drawing.SolidBrush $gemColors[$i]
        $gp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(80, 20, 8, 8)), 1
        Draw-Diamond $g $gb $gp ($canvasW / 2 + $gemXs[$i]) $gemY 6.5
        $gb.Dispose()
        $gp.Dispose()
    }

    $subY = $gemY + 22
    $subRect = New-Object System.Drawing.RectangleF 70, $subY, ($canvasW - 140), 44
    $subShadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(170, 0, 0, 0))
    $subBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(246, 236, 220))
    $shadowSub = New-Object System.Drawing.RectangleF $subRect.X, ($subRect.Y + 2), $subRect.Width, $subRect.Height
    $g.DrawString($shot.sub, $subFont, $subShadow, $shadowSub, $centerFmt)
    $g.DrawString($shot.sub, $subFont, $subBrush, $subRect, $centerFmt)
    $subShadow.Dispose()
    $subBrush.Dispose()

    $bezel = 16
    $phoneY = [int]($subY + 62)
    $phoneBottom = $canvasH - 34
    $outerH = $phoneBottom - $phoneY
    $innerH = $outerH - ($bezel * 2)
    $innerW = [int][Math]::Round($innerH * $cropW / $cropH)
    $outerW = $innerW + ($bezel * 2)
    $phoneX = [int](($canvasW - $outerW) / 2)

    $gr = $shot.glow
    $glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $glowPath.AddEllipse(($phoneX - 70), ($phoneY + 30), ($outerW + 140), ($outerH - 20))
    $glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush $glowPath
    $glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(110, $gr[0], $gr[1], $gr[2])
    $glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $gr[0], $gr[1], $gr[2]))
    $g.FillPath($glowBrush, $glowPath)
    $glowBrush.Dispose()
    $glowPath.Dispose()

    foreach ($layer in @(
            @{ a = 28; dy = 22; dx = 0 },
            @{ a = 40; dy = 12; dx = 0 },
            @{ a = 54; dy = 6; dx = 0 }
        )) {
        $sh = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($layer.a, 0, 0, 0))
        $sp = New-Object System.Drawing.Drawing2D.GraphicsPath
        Add-RoundRect $sp ($phoneX + $layer.dx) ($phoneY + $layer.dy) $outerW $outerH 46
        $g.FillPath($sh, $sp)
        $sp.Dispose()
        $sh.Dispose()
    }

    $shellRect = New-Object System.Drawing.Rectangle $phoneX, $phoneY, $outerW, $outerH
    $shellPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    Add-RoundRect $shellPath $phoneX $phoneY $outerW $outerH 46
    $shellBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $shellRect,
        ([System.Drawing.Color]::FromArgb(92, 78, 58)),
        ([System.Drawing.Color]::FromArgb(18, 14, 12)),
        ([System.Drawing.Drawing2D.LinearGradientMode]::Vertical))
    $g.FillPath($shellBrush, $shellPath)
    $rimPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(230, 214, 168, 78)), 2.5
    $g.DrawPath($rimPen, $shellPath)
    $rimPen.Dispose()
    $shellBrush.Dispose()
    $shellPath.Dispose()

    $body = 4
    $bodyPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    Add-RoundRect $bodyPath ($phoneX + $body) ($phoneY + $body) ($outerW - $body * 2) ($outerH - $body * 2) 42
    $bodyBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(12, 10, 9))
    $g.FillPath($bodyBrush, $bodyPath)
    $bodyBrush.Dispose()
    $bodyPath.Dispose()

    $ix = $phoneX + $bezel
    $iy = $phoneY + $bezel
    $clip = New-Object System.Drawing.Drawing2D.GraphicsPath
    Add-RoundRect $clip $ix $iy $innerW $innerH 32
    $g.SetClip($clip)
    $dest = New-Object System.Drawing.Rectangle $ix, $iy, $innerW, $innerH
    $srcRect = New-Object System.Drawing.Rectangle 0, $cropY, $cropW, $cropH
    $g.DrawImage($game, $dest, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.ResetClip()
    $clip.Dispose()

    if ($shot.sketch -and $sketchCache.ContainsKey($shot.sketch)) {
        $sk = $sketchCache[$shot.sketch]
        # Keep the walker tall but leave most of the phone UI readable.
        $drawH = [int]($outerH * 0.64)
        $drawW = [int]([Math]::Round($sk.Width * $drawH / [double]$sk.Height))
        if ($shot.sketchSide -eq 'right') {
            $sx = [single]($phoneX + $outerW - ($drawW * 0.48))
        } else {
            $sx = [single]($phoneX - ($drawW * 0.52))
        }
        $sy = [single]($phoneBottom - $drawH + 18)
        # Keep feet on-canvas; nudge in if the character overhangs too far.
        if ($sx -lt -40) { $sx = -40 }
        if (($sx + $drawW) -gt ($canvasW + 40)) { $sx = $canvasW + 40 - $drawW }

        $footShadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(110, 0, 0, 0))
        $shadowW = [single]($drawW * 0.55)
        $shadowH = [single]36
        $shadowX = $sx + (($drawW - $shadowW) / 2)
        $shadowY = $sy + $drawH - 28
        $g.FillEllipse($footShadow, $shadowX, $shadowY, $shadowW, $shadowH)
        $footShadow.Dispose()

        $g.DrawImage($sk, (New-Object System.Drawing.Rectangle ([int]$sx), ([int]$sy), $drawW, $drawH))

        $nameFont = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $name = [string]$shot.walker
        $nameWidth = [Math]::Max(132, [int]($g.MeasureString($name, $nameFont).Width + 18))
        $nameHeight = 24
        $nameX = $sx + (($drawW - $nameWidth) / 2)
        $nameY = $sy + $drawH - 8
        if ($nameY + $nameHeight -gt ($canvasH - 10)) {
            $nameY = $canvasH - 10 - $nameHeight
        }
        $pill = New-Object System.Drawing.Drawing2D.GraphicsPath
        Add-RoundRect $pill $nameX $nameY $nameWidth $nameHeight 12
        $pillBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 28, 12, 14))
        $g.FillPath($pillBrush, $pill)
        $pillBrush.Dispose()
        $pillPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(160, 214, 170, 78)), 1.25
        $g.DrawPath($pillPen, $pill)
        $pillPen.Dispose()
        $pill.Dispose()
        $nameBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(246, 228, 180))
        Draw-TrackedCenter $g $name $nameFont $nameBrush ($nameX + $nameWidth / 2) ($nameY + 4) 1.0
        $nameBrush.Dispose()
        $nameFont.Dispose()
    }

    $outPath = Join-Path $outDir $shot.out
    Save-Jpeg $canvas $outPath 92
    Write-Output ("{0}  {1}x{2}  {3}px title  {4:N0} KB" -f $shot.out, $canvas.Width, $canvas.Height, $titleSize, ((Get-Item $outPath).Length / 1KB))

    $titleFont.Dispose()
    $centerFmt.Dispose()
    $g.Dispose()
    $canvas.Dispose()
    $game.Dispose()
}

$kickerFont.Dispose()
$subFont.Dispose()
$titleFamily.Dispose()
foreach ($skName in @($sketchCache.Keys)) {
    $sketchCache[$skName].Dispose()
}
