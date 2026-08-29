# Cyberpunk 2077 Mod Files

This repository contains filtered Cyberpunk 2077 mod files found in:

`C:\Program Files\Epic Games\Cyberpunk2077`

The original game files are intentionally excluded. Mod paths are preserved relative to the game directory, so the downloaded folder can be copied back into a Cyberpunk 2077 install.

## Large Files

GitHub blocks normal repository files over 100 MiB, and Git LFS upload is blocked for this account/repository by quota:

`This repository exceeded its LFS budget.`

Because of that, files under 100 MiB are stored directly in their real game paths. Files over 100 MiB are stored as split parts under `_large_files/`.

After downloading or cloning this repository, run:

```powershell
.\Restore-LargeFiles.ps1
```

The script rebuilds the split files into their original paths, then verifies their size and SHA-256 hashes.

## Manifest

`MOD_MANIFEST.tsv` lists every included file sorted by relative path, with size and source last-write time.

## Filtered Areas

- `archive/pc/mod`
- `bin/x64/plugins`
- `bin/x64/cyber_engine_tweaks`
- selected `bin/x64` mod loader and graphics-mod files
- `engine/tools/scc.exe`
- `engine/tools/scc_lib.dll`
- selected `engine/config/platform/pc` mod config files
- `r6/audioware`
- `r6/config/cybercmd`
- `r6/config/redsUserHints`
- `r6/config/settings/platform/pc/options.json`
- `r6/input`
- `r6/scripts`
- `r6/tweaks`
- `red4ext`

## Excluded Runtime Data

Logs, caches, temporary files, and runtime session folders were excluded from the copy.
