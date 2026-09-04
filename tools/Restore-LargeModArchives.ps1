param(
    [string]$PartsDirectory = (Join-Path $PSScriptRoot '..\archive\pc\mod\_large_archive_parts'),
    [string]$DestinationDirectory = (Join-Path $PSScriptRoot '..\archive\pc\mod')
)

$ErrorActionPreference = 'Stop'
$PartsDirectory = [IO.Path]::GetFullPath($PartsDirectory)
$DestinationDirectory = [IO.Path]::GetFullPath($DestinationDirectory)

Get-ChildItem -LiteralPath $PartsDirectory -Directory | ForEach-Object {
    $archiveName = $_.Name
    $destination = Join-Path $DestinationDirectory $archiveName
    $parts = @(Get-ChildItem -LiteralPath $_.FullName -Filter '*.part*' -File | Sort-Object Name)
    if ($parts.Count -eq 0) { return }

    $output = [IO.File]::Open($destination, [IO.FileMode]::Create, [IO.FileAccess]::Write)
    try {
        foreach ($part in $parts) {
            $input = [IO.File]::OpenRead($part.FullName)
            try { $input.CopyTo($output) } finally { $input.Dispose() }
        }
    } finally { $output.Dispose() }

    Write-Host "Restored $archiveName"
}
