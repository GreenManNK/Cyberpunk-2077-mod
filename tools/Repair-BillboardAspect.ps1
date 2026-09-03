param(
    [string]$BuildRoot = 'C:\Users\NITRO\.codex\billboard-global-build'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Get-CoverRectangle {
    param([int]$SourceWidth, [int]$SourceHeight, [int]$TargetWidth, [int]$TargetHeight)
    $scale = [Math]::Max($TargetWidth / $SourceWidth, $TargetHeight / $SourceHeight)
    $width = [int][Math]::Ceiling($SourceWidth * $scale)
    $height = [int][Math]::Ceiling($SourceHeight * $scale)
    return [System.Drawing.Rectangle]::new([int](($TargetWidth - $width) / 2), [int](($TargetHeight - $height) / 2), $width, $height)
}

function Get-ContainRectangle {
    param([int]$SourceWidth, [int]$SourceHeight, [int]$TargetWidth, [int]$TargetHeight)
    $scale = [Math]::Min($TargetWidth / $SourceWidth, $TargetHeight / $SourceHeight)
    $width = [int][Math]::Round($SourceWidth * $scale)
    $height = [int][Math]::Round($SourceHeight * $scale)
    return [System.Drawing.Rectangle]::new([int](($TargetWidth - $width) / 2), [int](($TargetHeight - $height) / 2), $width, $height)
}

$sourceRoot = Join-Path $BuildRoot 'artwork'
$targetRoot = Join-Path $BuildRoot 'original-raw'
$outputRoot = Join-Path $BuildRoot 'corrected-artwork'
if (Test-Path -LiteralPath $outputRoot) {
    throw "Output already exists: $outputRoot"
}

$files = Get-ChildItem -LiteralPath $targetRoot -Recurse -Filter '*.png'
foreach ($target in $files) {
    $relativePath = $target.FullName.Substring($targetRoot.Length).TrimStart('\')
    $sourcePath = Join-Path $sourceRoot $relativePath
    if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Missing artwork source: $relativePath"
    }

    $destinationPath = Join-Path $outputRoot $relativePath
    [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($destinationPath)) | Out-Null
    $source = [System.Drawing.Image]::FromFile($sourcePath)
    $template = [System.Drawing.Image]::FromFile($target.FullName)
    try {
        $canvas = [System.Drawing.Bitmap]::new($template.Width, $template.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($canvas)
        try {
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $graphics.Clear([System.Drawing.Color]::Black)

            $sourceRatio = $source.Width / $source.Height
            $targetRatio = $canvas.Width / $canvas.Height
            $ratioDifference = [Math]::Abs([Math]::Log($sourceRatio / $targetRatio))

            if ($ratioDifference -lt 0.18) {
                # Similar display shapes: fill cleanly without rescaling either axis differently.
                $graphics.DrawImage($source, (Get-CoverRectangle $source.Width $source.Height $canvas.Width $canvas.Height))
            }
            else {
                # Different display shapes: retain the whole personal photo on a subdued matching backdrop.
                $graphics.DrawImage($source, (Get-CoverRectangle $source.Width $source.Height $canvas.Width $canvas.Height))
                $overlay = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(205, 0, 0, 0))
                try { $graphics.FillRectangle($overlay, 0, 0, $canvas.Width, $canvas.Height) } finally { $overlay.Dispose() }
                $graphics.DrawImage($source, (Get-ContainRectangle $source.Width $source.Height $canvas.Width $canvas.Height))
            }
            $canvas.Save($destinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
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

"Created $($files.Count) aspect-correct PNG files in $outputRoot"
