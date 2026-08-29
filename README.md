# Cyberpunk 2077 Mod Files

This repository contains filtered Cyberpunk 2077 mod files copied from:

`C:\Program Files\Epic Games\Cyberpunk2077`

The original game files are intentionally excluded. Mod files keep their original relative install paths, so they can be compared or restored back into the game directory.

## Manifest

`MOD_MANIFEST.tsv` lists every included file sorted by relative path, with size and source last-write time.

## Included Areas

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
