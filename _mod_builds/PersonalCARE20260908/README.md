# Personal CARE photo adverts

This build uses Community Ad Replacers Extended 1.95 as the resource template.
It assigns one distinct source photo to each of 167 campaign groups and renders
all campaign variants with aspect-aware cover cropping. Odd block-compressed
dimensions are padded by one pixel instead of stretching the image.

## Installed files

- `archive/pc/mod/Community_Ad_Replacers_Extended.archive`
- `archive/pc/mod/zzzzzzzzzzzzzzzzzz_Personal_CARE_Photos.archive`
- `r6/tweaks/Community_Ad_Replacers_Extended/care_pkg_records.yaml`
- `r6/tweaks/Community_Ad_Replacers_Extended/care_pkg_districts.yaml`

The personal archive contains exactly 682 resources: 531 XBM textures, 77 Ink
atlases, and 74 Ink widgets. Its SHA-256 is
`5937C97F6562EA40843E109D2359E8A6C5432ECD09B67E243F48DDB5FFC28D51`.

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
