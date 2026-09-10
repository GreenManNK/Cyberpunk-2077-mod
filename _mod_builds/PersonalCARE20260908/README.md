# Personal CARE photo adverts

This build uses Community Ad Replacers Extended 1.95 as the resource template.
It assigns one distinct source photo to each of 167 campaign groups and renders
all campaign variants with aspect-aware cover cropping. Odd block-compressed
dimensions are padded by one pixel instead of stretching the image.

## Installed files

- `archive/pc/mod/zzzzzzzzzzzzzzzzzz_Personal_CARE_Full.archive`
- `r6/tweaks/Community_Ad_Replacers_Extended/care_pkg_records.yaml`
- `r6/tweaks/Community_Ad_Replacers_Extended/care_pkg_districts.yaml`

The unified archive contains exactly 702 resources: 531 XBM textures, 77 Ink
atlases, 74 Ink widgets, and 20 CARE support resources. Its SHA-256 is
`64F02A52D18C0F3B52EEC6DD2155D74F20C51A7E82C77A8DE1A68BB08ACA3F4E`.

The atlas fix remaps all 2,448 named atlas regions to the full corresponding
photo. This covers world billboard consumers that access a region directly and
prevents the old template UV tiles from fragmenting the image.

The installed records YAML removes five invalid properties reported by TweakXL
1.11.4 on Cyberpunk 2077 2.31. The affected advertisement records retain their
format and library mappings.

## Build and recovery data

The deterministic builder is `tools/build_personal_ads_fullscreen.py`. Build
output, CSV manifests, and the contact sheet are stored at:

`C:\Users\NITRO\.codex\community-personal-ads-build-20260908\personal-care-v1`

Superseded advert files were moved, not deleted. The recovery root is:

`C:\Users\NITRO\.codex\mod-build-backups\20260908-community-personal-ads`

`disabled-advert-manifest.json` records all 39 disabled archives with their
original path, backup path, byte count, and SHA-256. The
`disabled-tweak-adverts` directory contains the corresponding manifest and
backup for `VirtualAtelierDelivery/NewAdvert.yaml`.
