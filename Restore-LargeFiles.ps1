$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ManifestPath = Join-Path $Root '_large_files\LARGE_FILE_PARTS.tsv'

if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "Missing large-file manifest: $ManifestPath"
}

$rows = Import-Csv -LiteralPath $ManifestPath -Delimiter "`t"
foreach ($group in ($rows | Group-Object original_path)) {
    $first = $group.Group[0]
    $target = Join-Path $Root ($first.original_path -replace '/', '\\')
    $targetDir = Split-Path -Parent $target
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

    $output = [System.IO.File]::Open($target, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
    try {
        foreach ($part in ($group.Group | Sort-Object {[int]$_.part_number})) {
            $partPath = Join-Path $Root ($part.part_path -replace '/', '\\')
            $input = [System.IO.File]::OpenRead($partPath)
            try { $input.CopyTo($output) } finally { $input.Dispose() }
        }
    } finally { $output.Dispose() }

    if ((Get-Item -LiteralPath $target).Length -ne [int64]$first.original_size_bytes) {
        throw "Size mismatch for $($first.original_path)"
    }
    if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant() -ne $first.original_sha256.ToLowerInvariant()) {
        throw "SHA-256 mismatch for $($first.original_path)"
    }
    Write-Host "Restored $($first.original_path)"
}
