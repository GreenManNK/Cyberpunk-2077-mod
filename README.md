# Cyberpunk 2077 active-mod snapshot

This repository mirrors the active mod configuration in this game directory. The
local machine is the source of truth.

## Included paths

- `archive/pc/mod`
- `bin/x64/plugins` and `bin/x64/cyber_engine_tweaks`
- `mods`
- `r6/audioware`, `r6/config/cybercmd`, `r6/config/redsUserHints`, `r6/input`,
  `r6/scripts`, and `r6/tweaks`
- `red4ext`

`MOD_MANIFEST.tsv` is generated from these active paths and records each file's
relative path, byte size, and UTC last-write time.

## Deliberately excluded

- `_disabled_mods` (mods explicitly disabled by the local cleanup)
- `_mod_backups` and `_tools` (backup/install staging data)
- logs, caches, temporary files, and generated redscript output

## Synchronization policy

Before committing, keep only the newest package for a Nexus mod ID. Do not
restore files recorded under `_disabled_mods`. Review any version downgrade or
conflict error in game logs before replacing an active framework.

## Personal CARE adverts

The active advert stack uses the unified
`zzzzzzzzzzzzzzzzzz_Personal_CARE_Full.archive`. It contains 531 textures, 77
atlases, 74 widgets, and 20 CARE support resources generated from 167 distinct
source photos. Keeping the support resources and personal replacements in one
archive removes load-order ambiguity.

The archive preserves all 2,448 named atlas UV regions. It draws a personal
photo only into the primary region of each of 229 atlas texture slots and keeps
the CARE artwork in every other region. This prevents direct billboard consumers
from showing fragments of a photograph.

The reproducible builder is `tools/build_personal_ads_fullscreen.py`. Its build
manifests and preview are stored outside the game drive under
`C:\Users\NITRO\.codex\community-personal-ads-build-20260908\personal-care-v1`.
The 39 superseded advert archives and the Virtual Atelier Delivery advert tweak
remain recoverable under
`C:\Users\NITRO\.codex\mod-build-backups\20260908-community-personal-ads`.
