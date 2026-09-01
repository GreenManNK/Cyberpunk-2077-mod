$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ManifestPath = Join-Path $Root '_large_files\LARGE_FILE_PARTS.tsv'

function Normalize-RepoPath([string]$PathValue) {
  return (($PathValue -replace '\\', '/').TrimStart('/'))
}

function Join-SafePath([string]$BasePath, [string]$RelativePath) {
  $normalized = Normalize-RepoPath $RelativePath
  $localPart = $normalized -replace '/', [IO.Path]::DirectorySeparatorChar
  $full = [IO.Path]::GetFullPath((Join-Path $BasePath $localPart))
  if (-not $full.StartsWith($BasePath, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing path outside restore root: $RelativePath"
  }
  return $full
}

function Get-Sha256([string]$PathValue) {
  $sha = [Security.Cryptography.SHA256]::Create()
  $stream = [IO.File]::OpenRead($PathValue)
  try {
    return ([BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-', '').ToLowerInvariant())
  } finally {
    $stream.Dispose()
    $sha.Dispose()
  }
}

if (-not (Test-Path -LiteralPath $ManifestPath)) {
  throw "Missing large-file manifest: $ManifestPath"
}

$rows = Import-Csv -LiteralPath $ManifestPath -Delimiter "`t"
$groups = $rows | Group-Object original_path
$index = 0

foreach ($group in $groups) {
  $index += 1
  $first = $group.Group[0]
  $target = Join-SafePath $Root $first.original_path
  $targetDir = Split-Path -Parent $target
  [IO.Directory]::CreateDirectory($targetDir) | Out-Null

  $tempTarget = "$target.restore_tmp"
  if (Test-Path -LiteralPath $tempTarget) {
    [IO.File]::SetAttributes($tempTarget, [IO.FileAttributes]::Normal)
    [IO.File]::Delete($tempTarget)
  }

  $output = [IO.File]::Create($tempTarget)
  try {
    foreach ($part in ($group.Group | Sort-Object { [int]$_.part_number })) {
      $partPath = Join-SafePath $Root $part.part_path
      $input = [IO.File]::OpenRead($partPath)
      try {
        $input.CopyTo($output)
      } finally {
        $input.Dispose()
      }

      if ($part.part_sha256) {
        $actualPartHash = Get-Sha256 $partPath
        if ($actualPartHash -ne $part.part_sha256.ToLowerInvariant()) {
          throw "SHA-256 mismatch for part $($part.part_path)"
        }
      }
    }
  } finally {
    $output.Dispose()
  }

  if ((Get-Item -LiteralPath $tempTarget).Length -ne [int64]$first.original_size_bytes) {
    throw "Size mismatch for $($first.original_path)"
  }

  $actualHash = Get-Sha256 $tempTarget
  if ($actualHash -ne $first.original_sha256.ToLowerInvariant()) {
    throw "SHA-256 mismatch for $($first.original_path)"
  }

  if (Test-Path -LiteralPath $target) {
    [IO.File]::SetAttributes($target, [IO.FileAttributes]::Normal)
    [IO.File]::Delete($target)
  }
  [IO.File]::Move($tempTarget, $target)

  Write-Host ("Restored {0}/{1}: {2}" -f $index, $groups.Count, $first.original_path)
}
