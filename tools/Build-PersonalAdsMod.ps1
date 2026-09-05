param(
    [string]$SourceRoot = 'H:\Crossout\0\s9\Thư mục mới (2)\JPG\Real Bitches\Chị em đĩ lồn Phạm Hà Anh',
    [string]$TemplateRoot = 'C:\Users\NITRO\.codex\billboard-global-build\templates',
    [string]$RawTemplateRoot = 'C:\Users\NITRO\.codex\billboard-global-build\original-raw',
    [string]$BuildRoot = 'F:\Cyberpunk2077\_tools\personal-ads-20260906\build',
    [string]$Cli = 'C:\Users\NITRO\.codex\tools\WolvenKitConsole-8.20.0\WolvenKit.CLI.exe'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

# One curated, non-explicit source photograph per separated advert archive.
# FocusX/FocusY identify the subject for aspect-fill crops without stretching.
$advertSources = [ordered]@{
    HotAdvertsSeperatedAbydos          = @{ File = '474902590_2036374613501231_7819982149814112129_n.jpg'; FocusX = 0.50; FocusY = 0.43 }
    HotAdvertsSeperatedAvante          = @{ File = '455691555_1915494992255861_6362284683027889548_n.jpg'; FocusX = 0.53; FocusY = 0.48 }
    HotAdvertsSeperatedBlastDance      = @{ File = '458201947_1926484157823611_9158669472117739800_n.jpg'; FocusX = 0.55; FocusY = 0.48 }
    HotAdvertsSeperatedBottomsUp       = @{ File = '471309182_2014814292323930_2396083255538623964_n.jpg'; FocusX = 0.50; FocusY = 0.39 }
    HotAdvertsSeperatedBroseph         = @{ File = '471359004_2014814365657256_8059694605900952501_n.jpg'; FocusX = 0.50; FocusY = 0.40 }
    HotAdvertsSeperatedBudgetArms      = @{ File = '474966793_2036374656834560_3578869787769721459_n.jpg'; FocusX = 0.50; FocusY = 0.43 }
    HotAdvertsSeperatedCaliente        = @{ File = '459656808_1936787226793304_5846236462423910661_n.jpg'; FocusX = 0.50; FocusY = 0.35 }
    HotAdvertsSeperatedChamparadise    = @{ File = '475012066_2036374620167897_6412010238617609356_n.jpg'; FocusX = 0.50; FocusY = 0.45 }
    HotAdvertsSeperatedChromanticore   = @{ File = '459815600_1936787203459973_4576990000658476429_n.jpg'; FocusX = 0.50; FocusY = 0.39 }
    HotAdvertsSeperatedDynalar         = @{ File = '459878772_1936787136793313_5235467301811613579_n.jpg'; FocusX = 0.49; FocusY = 0.39 }
    HotAdvertsSeperatedFuyutsuki       = @{ File = '459943085_1936787150126645_670340489633693564_n.jpg'; FocusX = 0.50; FocusY = 0.38 }
    HotAdvertsSeperatedGiovanni        = @{ File = '471475964_2014814345657258_1819204605942590051_n.jpg'; FocusX = 0.50; FocusY = 0.35 }
    HotAdvertsSeperatedGromorrah       = @{ File = '474624308_2034948746977151_5669578211178153424_n.jpg'; FocusX = 0.50; FocusY = 0.40 }
    HotAdvertsSeperatedJackiePinUp     = @{ File = '474702220_2034948800310479_2170012490314625120_n.jpg'; FocusX = 0.51; FocusY = 0.39 }
    HotAdvertsSeperatedJigJigBD        = @{ File = '474752801_2034948756977150_8710107786326924674_n.jpg'; FocusX = 0.50; FocusY = 0.40 }
    HotAdvertsSeperatedJigJigStars     = @{ File = '474777864_2034948790310480_5881804243722967916_n.jpg'; FocusX = 0.50; FocusY = 0.42 }
    HotAdvertsSeperatedJigJigTwerk     = @{ File = 'IMG_20230625_113014_922.jpg'; FocusX = 0.50; FocusY = 0.62 }
    HotAdvertsSeperatedJingujiShop     = @{ File = 'IMG_20230625_113014_969.jpg'; FocusX = 0.50; FocusY = 0.60 }
    HotAdvertsSeperatedJingujiStreet   = @{ File = 'IMG_20230625_113015_101.jpg'; FocusX = 0.50; FocusY = 0.60 }
    HotAdvertsSeperatedJoeTiel         = @{ File = 'IMG_20230625_113015_132.jpg'; FocusX = 0.50; FocusY = 0.55 }
    HotAdvertsSeperatedKangTao         = @{ File = 'IMG_20230625_113015_312.jpg'; FocusX = 0.50; FocusY = 0.39 }
    HotAdvertsSeperatedKiroshi         = @{ File = 'IMG_20230625_113015_432.jpg'; FocusX = 0.50; FocusY = 0.60 }
    HotAdvertsSeperatedLizzies         = @{ File = 'IMG_20230725_212635_817.jpg'; FocusX = 0.50; FocusY = 0.48 }
    HotAdvertsSeperatedMilfGaard       = @{ File = 'IMG_20230725_212635_701.jpg'; FocusX = 0.50; FocusY = 0.43 }
    HotAdvertsSeperatedMrStud          = @{ File = 'IMG_20230630_194243_792.jpg'; FocusX = 0.50; FocusY = 0.52 }
    HotAdvertsSeperatedNewEmpire       = @{ File = 'IMG_20230630_194245_659.jpg'; FocusX = 0.50; FocusY = 0.47 }
    HotAdvertsSeperatedRowdyDog        = @{ File = 'IMG_20230630_194250_303.jpg'; FocusX = 0.50; FocusY = 0.52 }
    HotAdvertsSeperatedSashaDevon      = @{ File = 'IMG_20230630_194620_216.jpg'; FocusX = 0.50; FocusY = 0.43 }
    HotAdvertsSeperatedSomalia         = @{ File = 'IMG_20230630_194623_840.jpg'; FocusX = 0.50; FocusY = 0.43 }
    HotAdvertsSeperatedSquirtaquisitor = @{ File = 'IMG_20230630_194626_338.jpg'; FocusX = 0.72; FocusY = 0.46 }
    HotAdvertsSeperatedSudo            = @{ File = 'IMG_20230630_195218_624.jpg'; FocusX = 0.50; FocusY = 0.37 }
    HotAdvertsSeperatedTampons         = @{ File = 'IMG_20230630_195221_913.jpg'; FocusX = 0.50; FocusY = 0.36 }
    HotAdvertsSeperatedTheBigEatShow   = @{ File = 'IMG_20230630_195227_389.jpg'; FocusX = 0.50; FocusY = 0.52 }
    HotAdvertsSeperatedWatsonWhore     = @{ File = 'IMG_20230725_212634_928.jpg'; FocusX = 0.50; FocusY = 0.40 }
    HotAdvertsSeperatedWetDream        = @{ File = 'IMG_20230725_212635_227.jpg'; FocusX = 0.50; FocusY = 0.46 }
    HotAdvertsSeperatedZeigDich        = @{ File = 'IMG_20230814_200200_862.jpg'; FocusX = 0.50; FocusY = 0.39 }
}

function Get-OrientedBitmap {
    param([Parameter(Mandatory)][string]$Path)

    $image = [System.Drawing.Image]::FromFile($Path)
    try {
        if ($image.PropertyIdList -contains 0x0112) {
            $orientation = $image.GetPropertyItem(0x0112).Value[0]
            $rotation = switch ($orientation) {
                2 { [System.Drawing.RotateFlipType]::RotateNoneFlipX }
                3 { [System.Drawing.RotateFlipType]::Rotate180FlipNone }
                4 { [System.Drawing.RotateFlipType]::Rotate180FlipX }
                5 { [System.Drawing.RotateFlipType]::Rotate90FlipX }
                6 { [System.Drawing.RotateFlipType]::Rotate90FlipNone }
                7 { [System.Drawing.RotateFlipType]::Rotate270FlipX }
                8 { [System.Drawing.RotateFlipType]::Rotate270FlipNone }
                default { [System.Drawing.RotateFlipType]::RotateNoneFlipNone }
            }
            $image.RotateFlip($rotation)
        }

        $copy = [System.Drawing.Bitmap]::new($image.Width, $image.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($copy)
        try {
            $graphics.DrawImageUnscaled($image, 0, 0)
        }
        finally {
            $graphics.Dispose()
        }
        return $copy
    }
    finally {
        $image.Dispose()
    }
}

function Get-AspectFillRectangle {
    param(
        [int]$SourceWidth,
        [int]$SourceHeight,
        [int]$TargetWidth,
        [int]$TargetHeight,
        [double]$FocusX,
        [double]$FocusY
    )

    $sourceRatio = $SourceWidth / $SourceHeight
    $targetRatio = $TargetWidth / $TargetHeight
    if ($sourceRatio -gt $targetRatio) {
        $cropHeight = $SourceHeight
        $cropWidth = [int][Math]::Round($SourceHeight * $targetRatio)
        $x = [int][Math]::Round(($SourceWidth * $FocusX) - ($cropWidth / 2))
        $x = [Math]::Max(0, [Math]::Min($x, $SourceWidth - $cropWidth))
        return [System.Drawing.Rectangle]::new($x, 0, $cropWidth, $cropHeight)
    }

    $cropWidth = $SourceWidth
    $cropHeight = [int][Math]::Round($SourceWidth / $targetRatio)
    $y = [int][Math]::Round(($SourceHeight * $FocusY) - ($cropHeight / 2))
    $y = [Math]::Max(0, [Math]::Min($y, $SourceHeight - $cropHeight))
    return [System.Drawing.Rectangle]::new(0, $y, $cropWidth, $cropHeight)
}

function Write-CroppedTexture {
    param(
        [Parameter(Mandatory)][string]$SourcePath,
        [Parameter(Mandatory)][string]$TemplatePng,
        [Parameter(Mandatory)][string]$DestinationPng,
        [double]$FocusX,
        [double]$FocusY
    )

    $source = Get-OrientedBitmap -Path $SourcePath
    $template = [System.Drawing.Image]::FromFile($TemplatePng)
    try {
        $canvas = [System.Drawing.Bitmap]::new($template.Width, $template.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($canvas)
        try {
            $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
            $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $sourceRect = Get-AspectFillRectangle -SourceWidth $source.Width -SourceHeight $source.Height -TargetWidth $canvas.Width -TargetHeight $canvas.Height -FocusX $FocusX -FocusY $FocusY
            $destinationRect = [System.Drawing.Rectangle]::new(0, 0, $canvas.Width, $canvas.Height)
            $graphics.DrawImage($source, $destinationRect, $sourceRect, [System.Drawing.GraphicsUnit]::Pixel)
            $canvas.SetResolution(96, 96)
            $canvas.Save($DestinationPng, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $graphics.Dispose()
            $canvas.Dispose()
        }
    }
    finally {
        $source.Dispose()
        $template.Dispose()
    }
}

foreach ($requiredPath in @($SourceRoot, $TemplateRoot, $RawTemplateRoot, $Cli)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Required path is missing: $requiredPath"
    }
}
if (Test-Path -LiteralPath $BuildRoot) {
    throw "Build output already exists; choose a new BuildRoot: $BuildRoot"
}

$sourceGroupsRoot = Join-Path $BuildRoot 'source-groups'
$archiveRoot = Join-Path $BuildRoot 'archives'
$previewRoot = Join-Path $BuildRoot 'preview'
[System.IO.Directory]::CreateDirectory($sourceGroupsRoot) | Out-Null
[System.IO.Directory]::CreateDirectory($archiveRoot) | Out-Null
[System.IO.Directory]::CreateDirectory($previewRoot) | Out-Null

$manifest = [System.Collections.Generic.List[object]]::new()
$representativePngs = [System.Collections.Generic.List[object]]::new()
foreach ($entry in $advertSources.GetEnumerator()) {
    $groupName = $entry.Key
    $selection = $entry.Value
    $sourcePath = Join-Path $SourceRoot $selection.File
    $templateGroup = Join-Path $TemplateRoot $groupName
    $groupRoot = Join-Path $sourceGroupsRoot $groupName
    if (-not (Test-Path -LiteralPath $sourcePath)) { throw "Missing selected image: $sourcePath" }
    if (-not (Test-Path -LiteralPath $templateGroup)) { throw "Missing template group: $templateGroup" }

    Copy-Item -LiteralPath $templateGroup -Destination $groupRoot -Recurse
    $xbmFiles = @(Get-ChildItem -LiteralPath $groupRoot -Recurse -Filter '*.xbm')
    $largestArea = -1L
    $representative = $null
    foreach ($xbm in $xbmFiles) {
        $relativePath = $xbm.FullName.Substring($groupRoot.Length).TrimStart('\')
        $templatePng = Join-Path $RawTemplateRoot ([System.IO.Path]::ChangeExtension($relativePath, '.png'))
        if (-not (Test-Path -LiteralPath $templatePng)) { throw "Missing raw template: $templatePng" }
        $destinationPng = [System.IO.Path]::ChangeExtension($xbm.FullName, '.png')
        Write-CroppedTexture -SourcePath $sourcePath -TemplatePng $templatePng -DestinationPng $destinationPng -FocusX $selection.FocusX -FocusY $selection.FocusY

        $dimensionProbe = [System.Drawing.Image]::FromFile($templatePng)
        try {
            $area = [long]$dimensionProbe.Width * [long]$dimensionProbe.Height
            if ($area -gt $largestArea) {
                $largestArea = $area
                $representative = $destinationPng
            }
        }
        finally {
            $dimensionProbe.Dispose()
        }
    }

    $directories = $xbmFiles | Group-Object DirectoryName | ForEach-Object Name
    foreach ($directory in $directories) {
        $pngs = @(Get-ChildItem -LiteralPath $directory -Filter '*.png' | ForEach-Object FullName)
        & $Cli import $pngs -o $directory --keep -v Minimal
        if ($LASTEXITCODE -ne 0) { throw "WolvenKit import failed for $directory" }
    }

    & $Cli pack $groupRoot -o $archiveRoot -v Minimal
    if ($LASTEXITCODE -ne 0) { throw "WolvenKit pack failed for $groupName" }
    $expectedArchive = Join-Path $archiveRoot ($groupName + '.archive')
    if (-not (Test-Path -LiteralPath $expectedArchive)) { throw "Expected archive was not created: $expectedArchive" }

    $manifest.Add([pscustomobject]@{
        Archive = $groupName + '.archive'
        SourceImage = $selection.File
        FocusX = $selection.FocusX
        FocusY = $selection.FocusY
        TextureCount = $xbmFiles.Count
    })
    $representativePngs.Add([pscustomobject]@{ Group = $groupName; Path = $representative })
}

$manifestPath = Join-Path $BuildRoot 'manifest.csv'
$manifest | Export-Csv -LiteralPath $manifestPath -NoTypeInformation -Encoding UTF8

# Six-by-six visual QA sheet using each archive's largest texture.
$columns = 6
$cellWidth = 360
$cellHeight = 260
$labelHeight = 28
$rows = [int][Math]::Ceiling($representativePngs.Count / $columns)
$sheet = [System.Drawing.Bitmap]::new($columns * $cellWidth, $rows * $cellHeight, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$sheetGraphics = [System.Drawing.Graphics]::FromImage($sheet)
$labelFont = [System.Drawing.Font]::new('Arial', 10, [System.Drawing.FontStyle]::Bold)
try {
    $sheetGraphics.Clear([System.Drawing.Color]::FromArgb(22, 22, 24))
    $sheetGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    for ($index = 0; $index -lt $representativePngs.Count; $index++) {
        $item = $representativePngs[$index]
        $column = $index % $columns
        $row = [int][Math]::Floor($index / $columns)
        $x = $column * $cellWidth
        $y = $row * $cellHeight
        $preview = [System.Drawing.Image]::FromFile($item.Path)
        try {
            $availableHeight = $cellHeight - $labelHeight
            $scale = [Math]::Min(($cellWidth - 8) / $preview.Width, ($availableHeight - 8) / $preview.Height)
            $width = [int][Math]::Round($preview.Width * $scale)
            $height = [int][Math]::Round($preview.Height * $scale)
            $drawX = $x + [int](($cellWidth - $width) / 2)
            $drawY = $y + [int](($availableHeight - $height) / 2)
            $sheetGraphics.DrawImage($preview, $drawX, $drawY, $width, $height)
        }
        finally {
            $preview.Dispose()
        }
        $label = $item.Group.Replace('HotAdvertsSeperated', '')
        $sheetGraphics.DrawString($label, $labelFont, [System.Drawing.Brushes]::White, $x + 6, $y + $cellHeight - $labelHeight + 4)
    }
    $sheet.Save((Join-Path $previewRoot 'all-adverts-preview.png'), [System.Drawing.Imaging.ImageFormat]::Png)
}
finally {
    $labelFont.Dispose()
    $sheetGraphics.Dispose()
    $sheet.Dispose()
}

$archives = @(Get-ChildItem -LiteralPath $archiveRoot -Filter '*.archive')
$textures = ($manifest | Measure-Object TextureCount -Sum).Sum
if ($archives.Count -ne 36 -or $textures -ne 115) {
    throw "Validation failed: archives=$($archives.Count), textures=$textures"
}

[pscustomobject]@{
    Archives = $archives.Count
    Textures = $textures
    Output = $archiveRoot
    Preview = Join-Path $previewRoot 'all-adverts-preview.png'
    Manifest = $manifestPath
}
