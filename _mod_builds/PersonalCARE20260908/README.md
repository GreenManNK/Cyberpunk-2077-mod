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
`9AE9D2A46F09659D311E81F7D1FC3BB12C8F7CFFFA7CABBDA88088CC76E7C0A9`.

The atlas-layout fix preserves all 2,448 original UV regions. A personal photo
is rendered only into the primary region of each of 229 atlas texture slots;
the remaining CARE artwork is retained so directly addressed billboard regions
cannot fragment the photo.

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
