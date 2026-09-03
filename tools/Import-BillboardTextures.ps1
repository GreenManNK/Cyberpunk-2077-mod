param(
    [string]$Root = 'C:\Users\NITRO\.codex\billboard-global-build\corrected-artwork',
    [string]$Cli = 'C:\Users\NITRO\.codex\tools\WolvenKitConsole-8.20.0\WolvenKit.CLI.exe',
    [string]$LogPath = 'C:\Users\NITRO\.codex\billboard-global-build\aspect-import.log',
    [string]$DonePath = 'C:\Users\NITRO\.codex\billboard-global-build\aspect-import.done'
)

$ErrorActionPreference = 'Stop'
if (Test-Path -LiteralPath $DonePath) { Remove-Item -LiteralPath $DonePath -Force }
"Started $(Get-Date -Format o)" | Set-Content -LiteralPath $LogPath
$directories = Get-ChildItem -LiteralPath $Root -Recurse -Filter '*.png' |
    Group-Object DirectoryName | ForEach-Object Name
$failed = @()

for ($index = 0; $index -lt $directories.Count; $index += 4) {
    $end = [Math]::Min($index + 3, $directories.Count - 1)
    $batch = $directories[$index..$end]
    $jobs = foreach ($directory in $batch) {
        Start-Job -ArgumentList $Cli, $directory -ScriptBlock {
            param($Tool, $Folder)
            $images = Get-ChildItem -LiteralPath $Folder -Filter '*.png' | ForEach-Object FullName
            & $Tool import $images -o $Folder --keep -v Quiet
            exit $LASTEXITCODE
        }
    }
    Wait-Job -Job $jobs | Out-Null
    foreach ($job in $jobs) {
        $result = Receive-Job -Job $job
        if ($job.State -ne 'Completed' -or $result -ne 0) { $failed += $job.Id }
        Remove-Job -Job $job
    }
    "Finished groups $($end + 1) of $($directories.Count) at $(Get-Date -Format T)" |
        Add-Content -LiteralPath $LogPath
}

if ($failed.Count) {
    "FAILED: $($failed -join ',')" | Add-Content -LiteralPath $LogPath
    exit 1
}
"Completed $(Get-Date -Format o)" | Set-Content -LiteralPath $DonePath
