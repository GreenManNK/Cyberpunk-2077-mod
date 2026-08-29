# Cyberpunk 2077 Mod Files

This repository contains a filtered manifest for Cyberpunk 2077 mod files found in:

`C:\Program Files\Epic Games\Cyberpunk2077`

The original game files are intentionally excluded. Mod paths are preserved relative to the game directory, so the manifest can be used to compare or restore the same layout.

## Upload Status

The full mod file upload is currently blocked by GitHub LFS quota:

`This repository exceeded its LFS budget.`

The filtered mod set was prepared locally as 3,218 files totaling about 4.98 GiB, but GitHub rejected the LFS upload before accepting the file commit. Only this README, `.gitattributes`, `.gitignore`, and `MOD_MANIFEST.tsv` are pushed right now.

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
