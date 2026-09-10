param(
    [string]$GameRoot = 'F:\Cyberpunk2077',
    [string]$TemplateZip = 'C:\Users\NITRO\Downloads\Community Ad Replacers Extended-26538-1-95-1774422890.zip',
    [string]$BuildRoot = 'C:\Users\NITRO\.codex\community-personal-ads-build-20260908',
    [string]$BackupRoot = 'C:\Users\NITRO\.codex\mod-build-backups\20260908-community-personal-ads'
)

$ErrorActionPreference = 'Stop'

if (Get-Process -Name Cyberpunk2077 -ErrorAction SilentlyContinue) {
    throw 'Close Cyberpunk 2077 before changing advert mods.'
}

foreach ($path in @($GameRoot, $TemplateZip)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required path is missing: $path"
    }
}
if (Test-Path -LiteralPath $BuildRoot) {
    throw "Build folder already exists; refusing to overwrite it: $BuildRoot"
}

$oldBuild = Join-Path $GameRoot '_mod_builds\PersonalAdsLuxuryLite20260908'
if (-not (Test-Path -LiteralPath $oldBuild -PathType Container)) {
    throw "Expected prior advert build was not found: $oldBuild"
}

$adRoot = Join-Path $GameRoot 'archive\pc\mod'
$advertMods = @(
    Get-ChildItem -LiteralPath $adRoot -Filter 'HotAdvertsSeperated*.archive' -File |
        Sort-Object Name
)
foreach ($name in @(
    'zzzzzzzzzzzzzzzz_personal_ads_stable_nonatlas_v2.archive',
    'Always_Best_Quality.archive',
    'NSFW Vending Machine.archive'
)) {
    $path = Join-Path $adRoot $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Expected active advert mod was not found: $path"
    }
    $advertMods += Get-Item -LiteralPath $path
}
if ($advertMods.Count -ne 39) {
    throw "Expected 39 conflicting advert archives; found $($advertMods.Count)."
}

$fDrive = Get-PSDrive -Name F
$cDrive = Get-PSDrive -Name C
if ($cDrive.Free -lt 4GB) {
    throw 'At least 4 GiB must be free on C: for the reversible backup and build workspace.'
}

New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
$oldBuildBackup = Join-Path $BackupRoot 'PersonalAdsLuxuryLite20260908'
if (Test-Path -LiteralPath $oldBuildBackup) {
    throw "Backup destination already exists; refusing to overwrite it: $oldBuildBackup"
}
$modsBackup = Join-Path $BackupRoot 'disabled-advert-archives'
New-Item -ItemType Directory -Force -Path $modsBackup | Out-Null

$manifest = [System.Collections.Generic.List[object]]::new()
foreach ($mod in $advertMods) {
    $manifest.Add([pscustomobject]@{
        OriginalPath = $mod.FullName
        BackupPath = Join-Path $modsBackup $mod.Name
        Bytes = $mod.Length
        Sha256 = (Get-FileHash -LiteralPath $mod.FullName -Algorithm SHA256).Hash
    })
}

# These are generated intermediates only. Moving them is reversible and frees
# enough room on the game drive for the final companion archive.
Move-Item -LiteralPath $oldBuild -Destination $oldBuildBackup -ErrorAction Stop
foreach ($entry in $manifest) {
    Move-Item -LiteralPath $entry.OriginalPath -Destination $entry.BackupPath -ErrorAction Stop
}
$manifest | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $BackupRoot 'disabled-advert-manifest.json') -Encoding UTF8

New-Item -ItemType Directory -Force -Path $BuildRoot | Out-Null
Expand-Archive -LiteralPath $TemplateZip -DestinationPath (Join-Path $BuildRoot 'source-package') -Force

$report = [pscustomobject]@{
    DisabledAdvertArchives = $manifest.Count
    DisabledMiB = [math]::Round((($manifest | Measure-Object -Property Bytes -Sum).Sum) / 1MB, 2)
    PriorBuildBackup = $oldBuildBackup
    BuildRoot = $BuildRoot
    GameDriveFreeGiB = [math]::Round((Get-PSDrive -Name F).Free / 1GB, 2)
    SystemDriveFreeGiB = [math]::Round((Get-PSDrive -Name C).Free / 1GB, 2)
}
$report | Format-List
