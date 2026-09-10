#!/usr/bin/env python3
"""Build a full-screen replacement for Cyberpunk 2077 world adverts.

The stock adverts are INK widgets composed from many sprites in texture atlases.
Replacing an entire atlas with one photograph makes every sprite sample a random
piece of that photograph, which produces the familiar mosaic/striping failure.

This builder keeps the stock XBM formats but:
  * expands one existing atlas part to the full texture;
  * reduces every advert library item to one centered image widget;
  * disables the old animation sequences; and
  * replaces all world-advert textures, including 720p/1080p/UltraHD slots.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import re
import shutil
import subprocess
import sys
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path, PureWindowsPath

from PIL import Image, ImageDraw, ImageFont, ImageOps


REPO_ROOT = Path(__file__).resolve().parents[1]
CARE_WORK_ROOT = Path.home() / ".codex" / "community-personal-ads-build-20260908"


# Preserve the hand-picked photographs and focal points from the first build.
# Groups not listed here rotate through the same curated pool deterministically.
CURATED = {
    "abydos": ("474902590_2036374613501231_7819982149814112129_n.jpg", 0.50, 0.43),
    "avante": ("455691555_1915494992255861_6362284683027889548_n.jpg", 0.53, 0.48),
    "blastdance": ("458201947_1926484157823611_9158669472117739800_n.jpg", 0.55, 0.48),
    "bottomsup": ("471309182_2014814292323930_2396083255538623964_n.jpg", 0.50, 0.39),
    "broseph": ("471359004_2014814365657256_8059694605900952501_n.jpg", 0.50, 0.40),
    "budget_arms02": ("474966793_2036374656834560_3578869787769721459_n.jpg", 0.50, 0.43),
    "caliente": ("459656808_1936787226793304_5846236462423910661_n.jpg", 0.50, 0.35),
    "champaradise": ("475012066_2036374620167897_6412010238617609356_n.jpg", 0.50, 0.45),
    "dynalar": ("459878772_1936787136793313_5235467301811613579_n.jpg", 0.49, 0.39),
    "fuyutsuki_boombox": ("459943085_1936787150126645_670340489633693564_n.jpg", 0.50, 0.38),
    "giovanni_brizzi": ("471475964_2014814345657258_1819204605942590051_n.jpg", 0.50, 0.35),
    "gomorrah": ("474624308_2034948746977151_5669578211178153424_n.jpg", 0.50, 0.40),
    "jigjig_braindance": ("474752801_2034948756977150_8710107786326924674_n.jpg", 0.50, 0.40),
    "jigjig_stars": ("474777864_2034948790310480_5881804243722967916_n.jpg", 0.50, 0.42),
    "jigjig_twerk": ("IMG_20230625_113014_922.jpg", 0.50, 0.62),
    "jinguji_street": ("IMG_20230625_113015_101.jpg", 0.50, 0.60),
    "jingujishop": ("IMG_20230625_113014_969.jpg", 0.50, 0.60),
    "joe_tiel": ("IMG_20230625_113015_132.jpg", 0.50, 0.55),
    "kangtao": ("IMG_20230625_113015_312.jpg", 0.50, 0.39),
    "kiroshi": ("IMG_20230625_113015_432.jpg", 0.50, 0.60),
    "lizzies": ("IMG_20230725_212635_817.jpg", 0.50, 0.48),
    "milfgaard": ("IMG_20230725_212635_701.jpg", 0.50, 0.43),
    "mrstud": ("IMG_20230630_194243_792.jpg", 0.50, 0.52),
    "new_empire": ("IMG_20230630_194245_659.jpg", 0.50, 0.47),
    "rowdydog": ("IMG_20230630_194250_303.jpg", 0.50, 0.52),
    "sasha_devon": ("IMG_20230630_194620_216.jpg", 0.50, 0.43),
    "schade_zeig_dich": ("IMG_20230814_200200_862.jpg", 0.50, 0.39),
    "somalia": ("IMG_20230630_194623_840.jpg", 0.50, 0.43),
    "squirtaquisitor": ("IMG_20230630_194626_338.jpg", 0.72, 0.46),
    "sudo": ("IMG_20230630_195218_624.jpg", 0.50, 0.37),
    "tampons": ("IMG_20230630_195221_913.jpg", 0.50, 0.36),
    "the_big_eat_show": ("IMG_20230630_195227_389.jpg", 0.50, 0.52),
    "watson_whore": ("IMG_20230725_212634_928.jpg", 0.50, 0.40),
    "wet_dream": ("IMG_20230725_212635_227.jpg", 0.50, 0.46),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source-root",
        type=Path,
        default=Path(r"H:\Crossout\0\s9\Thư mục mới (2)\JPG\Real Bitches\Chị em đĩ lồn Phạm Hà Anh"),
    )
    parser.add_argument(
        "--asset-root",
        type=Path,
        default=CARE_WORK_ROOT / "care-assets",
    )
    parser.add_argument(
        "--build-root",
        type=Path,
        default=CARE_WORK_ROOT / "personal-care-v1",
    )
    parser.add_argument(
        "--cli",
        type=Path,
        default=REPO_ROOT / "_tools" / "wolvenkit-cli" / "cp77tools.exe",
    )
    parser.add_argument(
        "--install-dir",
        type=Path,
        default=REPO_ROOT / "archive" / "pc" / "mod",
    )
    parser.add_argument(
        "--archive-name",
        default="zzzzzzzzzzzzzzzzzz_Personal_CARE_Photos.archive",
    )
    parser.add_argument("--photo-count", type=int, default=167)
    parser.add_argument("--expected-textures", type=int, default=531)
    parser.add_argument("--import-workers", type=int, default=1)
    parser.add_argument("--resume-stage", action="store_true")
    parser.add_argument("--no-install", action="store_true")
    return parser.parse_args()


def norm_depot(value: str) -> str:
    return value.replace("/", "\\").lower()


def texture_family(stem: str) -> str:
    value = stem.lower()
    value = re.sub(r"_(720p|1080p)$", "", value)
    value = re.sub(r"_atlas(?:_02)?$", "", value)
    value = re.sub(r"_(16_9|21_9|3_3_1|3_4|9_16)$", "", value)
    return value


def depot_group(value: str) -> str:
    parts = PureWindowsPath(value).parts
    lowered = [part.lower() for part in parts]
    stem = texture_family(PureWindowsPath(value).stem)
    if "ads_extended" in lowered:
        index = lowered.index("ads_extended")
        author = lowered[index + 1] if index + 1 < len(lowered) - 1 else "root"
        stem = stem.replace("wetdream_", "wet_dream_")
        return f"extended:{author}:{stem}"
    try:
        index = lowered.index("adverts")
    except ValueError:
        joined = "\\".join(lowered)
        if "mayor_campaign" in joined:
            package = "mayor_campaign"
        elif "sq023" in lowered:
            package = "sq023"
        elif any(part.startswith("vector_boards_ratio_") for part in lowered):
            package = "vector_board_masks"
        elif "animated" in lowered and stem.startswith("ads_set_"):
            package = "animated_textures"
        else:
            package = "asian_banner"
        return f"base:external:{package}"
    folder = lowered[index + 1] if index + 1 < len(lowered) - 1 else "root"
    return f"base:{folder}:{stem}"


def depot_value(node: object) -> str | None:
    if not isinstance(node, dict):
        return None
    depot = node.get("DepotPath")
    if isinstance(depot, dict):
        value = depot.get("$value")
        if isinstance(value, str):
            return value
    return None


def part_name(part: dict) -> str:
    name = part.get("partName", {})
    return name.get("$value", "") if isinstance(name, dict) else ""


def rect_area(part: dict) -> float:
    rect = part.get("clippingRectInUVCoords", {})
    try:
        return max(0.0, float(rect["Right"]) - float(rect["Left"])) * max(
            0.0, float(rect["Bottom"]) - float(rect["Top"])
        )
    except (KeyError, TypeError, ValueError):
        return 0.0


def choose_universal_part(slots: list[dict]) -> str:
    slot_names: list[set[str]] = []
    areas: dict[str, list[float]] = defaultdict(list)
    spelling: dict[str, str] = {}
    for slot in slots:
        names: set[str] = set()
        for part in slot.get("parts", []):
            name = part_name(part)
            if not name:
                continue
            key = name.lower()
            names.add(key)
            spelling.setdefault(key, name)
            areas[key].append(rect_area(part))
        if names:
            slot_names.append(names)
    if not slot_names:
        raise ValueError("Atlas has no named parts")
    common = set.intersection(*slot_names)
    if not common:
        raise ValueError("Atlas slots have no common part")

    preferred = re.compile(r"(^|_)(background|bg\d*|base|main|screen|full|image|default|advert)(_|$)", re.I)

    def score(key: str) -> tuple[int, float]:
        values = areas[key]
        return (1 if preferred.search(key) else 0, sum(values) / len(values))

    key = max(common, key=score)
    return spelling[key]


def find_original_by_name(root: Path, suffix: str) -> dict[str, Path]:
    result: dict[str, Path] = {}
    for path in root.rglob(f"*{suffix}"):
        key = path.name.lower()
        if key in result:
            raise RuntimeError(f"Duplicate basename: {path.name}")
        result[key] = path
    return result


def prepare_atlases(asset_root: Path, modified_json: Path) -> tuple[dict[str, dict], list[dict]]:
    originals = find_original_by_name(asset_root / "all-atlases", ".inkatlas")
    infos: dict[str, dict] = {}
    reports: list[dict] = []

    for source_json in sorted((asset_root / "all-atlases-json").glob("*.json")):
        original = originals.get(source_json.name.removesuffix(".json").lower())
        if original is None:
            raise RuntimeError(f"No original atlas for {source_json.name}")
        depot_path = norm_depot(str(original.relative_to(asset_root / "all-atlases")))
        with source_json.open("r", encoding="utf-8-sig") as handle:
            document = json.load(handle)
        slots = document["Data"]["RootChunk"]["slots"]["Elements"]
        chosen = choose_universal_part(slots)
        texture_paths: list[str] = []
        for slot in slots:
            parts = slot.get("parts", [])
            # A few stock atlases contain an intentionally empty fallback slot
            # (texture depot path 0). It is not a renderable resolution tier.
            if not parts:
                continue
            texture = depot_value(slot.get("texture"))
            if texture and texture != "0":
                texture_paths.append(norm_depot(texture))
            match = None
            for part in parts:
                if part_name(part).lower() == chosen.lower():
                    match = part
                    break
            if match is None:
                raise RuntimeError(f"Part {chosen!r} is missing from a slot in {depot_path}")
            rect = match["clippingRectInUVCoords"]
            rect["Left"], rect["Top"], rect["Right"], rect["Bottom"] = 0, 0, 1, 1

        destination = modified_json / source_json.name
        with destination.open("w", encoding="utf-8", newline="\n") as handle:
            json.dump(document, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
        infos[depot_path] = {
            "part": chosen,
            "textures": texture_paths,
            "original": original,
        }
        reports.append({"atlas": depot_path, "part": chosen, "textures": len(texture_paths)})
    return infos, reports


def image_wrappers(node: object):
    if isinstance(node, dict):
        data = node.get("Data")
        if isinstance(data, dict) and data.get("$type") == "inkImageWidget":
            yield node
        for value in node.values():
            yield from image_wrappers(value)
    elif isinstance(node, list):
        for value in node:
            yield from image_wrappers(value)


def root_wrappers(library_item: dict):
    package = library_item.get("package", {})
    root = package.get("Data", {}).get("File", {}).get("RootChunk", {}).get("rootWidget")
    if isinstance(root, dict):
        yield root
    chunks = library_item.get("packageData", {}).get("Data", {}).get("Chunks", [])
    for chunk in chunks:
        if isinstance(chunk, dict):
            root = chunk.get("rootWidget")
            if isinstance(root, dict):
                yield root


def reset_vector(vector: object, x: float, y: float) -> None:
    if isinstance(vector, dict):
        vector["X"], vector["Y"] = x, y


def simplify_root(root: dict, atlas_infos: dict[str, dict]) -> tuple[bool, str | None]:
    root_data = root.get("Data")
    if not isinstance(root_data, dict):
        return False, None
    candidates = []
    for wrapper in image_wrappers(root_data):
        image = wrapper["Data"]
        atlas_path = depot_value(image.get("textureAtlas"))
        if atlas_path and norm_depot(atlas_path) in atlas_infos:
            candidates.append((wrapper, norm_depot(atlas_path)))
    if not candidates:
        return False, None

    selected, atlas_path = candidates[0]
    image = selected["Data"]
    atlas = atlas_infos[atlas_path]
    image.setdefault("texturePart", {})["$value"] = atlas["part"]
    image["fitToContent"] = 0
    image["visible"] = 1
    image["opacity"] = 1
    image["contentHAlign"] = "Fill"
    image["contentVAlign"] = "Fill"
    image["horizontalTileCrop"] = 0
    image["verticalTileCrop"] = 0
    image["tileType"] = "NoTile"
    image["mirrorType"] = "NoMirror"

    size = root_data.get("size", {})
    width = float(size.get("X", 32) or 32)
    height = float(size.get("Y", 32) or 32)
    image_size = image.setdefault("size", {"$type": "Vector2"})
    image_size["X"], image_size["Y"] = width, height

    layout = image.setdefault("layout", {})
    layout["anchor"] = "TopLeft"
    layout["HAlign"] = "Left"
    layout["VAlign"] = "Top"
    layout["sizeRule"] = "Fixed"
    layout["sizeCoefficient"] = 1
    reset_vector(layout.setdefault("anchorPoint", {"$type": "Vector2"}), 0, 0)
    margin = layout.setdefault("margin", {})
    padding = layout.setdefault("padding", {})
    for edge in ("left", "top", "right", "bottom"):
        margin[edge] = 0
        padding[edge] = 0

    transform = image.setdefault("renderTransform", {})
    transform["rotation"] = 0
    reset_vector(transform.setdefault("scale", {"$type": "Vector2"}), 1, 1)
    reset_vector(transform.setdefault("shear", {"$type": "Vector2"}), 0, 0)
    reset_vector(transform.setdefault("translation", {"$type": "Vector2"}), 0, 0)
    reset_vector(image.setdefault("renderTransformPivot", {"$type": "Vector2"}), 0.5, 0.5)

    parent = image.setdefault("parentWidget", {})
    parent.clear()
    parent["HandleRefId"] = str(root.get("HandleId", "0"))
    children = root_data.get("children")
    if not isinstance(children, dict) or not isinstance(children.get("Data"), dict):
        return False, None
    children["Data"]["children"] = [selected]
    root_data["childOrder"] = "Backward"
    return True, atlas_path


def prepare_widgets(asset_root: Path, modified_json: Path, atlas_infos: dict[str, dict]) -> tuple[list[dict], dict[str, Path]]:
    originals = find_original_by_name(asset_root / "all-widgets", ".inkwidget")
    reports: list[dict] = []
    output_to_original: dict[str, Path] = {}
    for source_json in sorted((asset_root / "all-widgets-json").glob("*.json")):
        original = originals.get(source_json.name.removesuffix(".json").lower())
        if original is None:
            raise RuntimeError(f"No original widget for {source_json.name}")
        with source_json.open("r", encoding="utf-8-sig") as handle:
            document = json.load(handle)
        root_chunk = document["Data"]["RootChunk"]
        root_chunk["sequences"] = []
        changed = 0
        used_atlases: set[str] = set()
        skipped = 0
        for item in root_chunk.get("libraryItems", []):
            item_changed = False
            for root in root_wrappers(item):
                ok, atlas_path = simplify_root(root, atlas_infos)
                if ok:
                    changed += 1
                    item_changed = True
                    if atlas_path:
                        used_atlases.add(atlas_path)
            if not item_changed:
                skipped += 1
        if not changed:
            # Some root helper widgets have no image of their own. Keep them out
            # of the override archive rather than rewriting unchanged resources.
            continue
        destination = modified_json / source_json.name
        with destination.open("w", encoding="utf-8", newline="\n") as handle:
            json.dump(document, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
        output_to_original[source_json.name.removesuffix(".json").lower()] = original
        reports.append(
            {
                "widget": norm_depot(str(original.relative_to(asset_root / "all-widgets"))),
                "roots_changed": changed,
                "library_items_without_images": skipped,
                "atlases": ";".join(sorted(used_atlases)),
            }
        )
    return reports, output_to_original


def run(command: list[str | Path], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    rendered = [str(value) for value in command]
    print("+", subprocess.list2cmdline(rendered), flush=True)
    return subprocess.run(rendered, check=True, text=True, capture_output=capture)


def import_texture_buffers(cli: Path, stage: Path, workers: int) -> int:
    """Import in small batches; WolvenKit 8.20 does not discover these PNGs
    when only the common parent directory is passed on Windows.
    """
    directories = sorted({path.parent for path in stage.rglob("*.png")})
    already_imported = 0
    pending: list[tuple[Path, list[Path]]] = []
    for directory in directories:
        pngs = sorted(directory.glob("*.png"))
        # This also makes interrupted builds resumable. A successful --keep
        # import rewrites the matching XBM after its freshly rendered PNG.
        if all(
            png.with_suffix(".xbm").is_file()
            and png.with_suffix(".xbm").stat().st_mtime > png.stat().st_mtime
            for png in pngs
        ):
            already_imported += len(pngs)
        else:
            pending.append((directory, pngs))

    def import_directory(item: tuple[Path, list[Path]]) -> int:
        directory, pngs = item
        command = [
            str(cli),
            "import",
            *(str(path) for path in pngs),
            "-o",
            str(directory),
            "--keep",
            "-v",
            "Quiet",
        ]
        completed = subprocess.run(command, text=True, capture_output=True)
        if completed.returncode:
            raise RuntimeError(
                f"Texture import failed for {directory}:\n{completed.stdout}\n{completed.stderr}"
            )
        unchanged = [
            png.name
            for png in pngs
            if not png.with_suffix(".xbm").is_file()
            or png.with_suffix(".xbm").stat().st_mtime <= png.stat().st_mtime
        ]
        if unchanged:
            raise RuntimeError(
                f"Texture import silently skipped {len(unchanged)} file(s) in {directory}: "
                + ", ".join(unchanged)
            )
        return len(pngs)

    imported = already_imported
    with ThreadPoolExecutor(max_workers=max(1, workers)) as executor:
        futures = [executor.submit(import_directory, item) for item in pending]
        for index, future in enumerate(as_completed(futures), 1):
            imported += future.result()
            if index % 20 == 0 or index == len(futures):
                completed_dirs = len(directories) - len(pending) + index
                print(
                    f"Imported {imported} texture buffers from {completed_dirs}/{len(directories)} directories",
                    flush=True,
                )
    return imported


def copy_deserialized(
    binary_flat: Path,
    stage: Path,
    asset_root: Path,
    atlas_infos: dict[str, dict],
    widget_originals: dict[str, Path],
) -> tuple[int, int]:
    atlas_count = 0
    for info in atlas_infos.values():
        name = info["original"].name
        generated = binary_flat / name
        if not generated.is_file():
            raise RuntimeError(f"Missing deserialized atlas: {generated}")
        relative = info["original"].relative_to(asset_root / "all-atlases")
        destination = stage / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(generated, destination)
        atlas_count += 1

    widget_count = 0
    for name, original in widget_originals.items():
        generated = binary_flat / original.name
        if not generated.is_file():
            raise RuntimeError(f"Missing deserialized widget: {generated}")
        relative = original.relative_to(asset_root / "all-widgets")
        destination = stage / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(generated, destination)
        widget_count += 1
    return atlas_count, widget_count


def source_files(source_root: Path, desired: int) -> list[Path]:
    """Select a stable, unique pool without interpreting or altering its content."""
    if desired < 1:
        raise ValueError("Photo count must be positive")

    available = sorted(
        (
            path
            for path in source_root.rglob("*")
            if path.is_file() and path.suffix.lower() in {".jpg", ".jpeg"}
        ),
        key=lambda path: path.relative_to(source_root).as_posix().casefold(),
    )
    by_name: dict[str, Path] = {}
    for path in available:
        by_name.setdefault(path.name.casefold(), path)

    ordered: list[Path] = []
    for filename, _, _ in dict.fromkeys(CURATED.values()):
        path = by_name.get(filename.casefold())
        if path is not None:
            ordered.append(path)

    curated_set = set(ordered)
    remaining = [path for path in available if path not in curated_set]
    remaining.sort(
        key=lambda path: hashlib.sha256(
            path.relative_to(source_root).as_posix().casefold().encode("utf-8")
        ).digest()
    )
    ordered.extend(remaining)

    selected: list[Path] = []
    content_hashes: set[str] = set()
    for path in ordered:
        try:
            with Image.open(path) as image:
                width, height = ImageOps.exif_transpose(image).size
            if min(width, height) < 720 or width * height < 1_000_000:
                continue
            with path.open("rb") as handle:
                digest = hashlib.file_digest(handle, "sha256").hexdigest()
        except (OSError, ValueError):
            continue
        if digest in content_hashes:
            continue
        content_hashes.add(digest)
        selected.append(path)
        if len(selected) == desired:
            break

    if len(selected) != desired:
        raise RuntimeError(
            f"Expected {desired} usable unique source photographs, found {len(selected)}"
        )
    return selected


def focus_for_source(source: Path) -> tuple[float, float]:
    for filename, focus_x, focus_y in CURATED.values():
        if source.name.casefold() == filename.casefold():
            return focus_x, focus_y
    return 0.50, 0.42


def assign_sources(groups: list[str], pool: list[Path]) -> dict[str, tuple[Path, float, float]]:
    by_name = {path.name.casefold(): path for path in pool}
    unused = set(pool)
    selections: dict[str, tuple[Path, float, float]] = {}

    # Give each known campaign its previously reviewed photo once.
    for group in groups:
        for key, (filename, focus_x, focus_y) in CURATED.items():
            source = by_name.get(filename.casefold())
            if key in group and source in unused:
                selections[group] = (source, focus_x, focus_y)
                unused.remove(source)
                break

    available = [path for path in pool if path in unused]
    available_index = 0
    repeat_index = 0
    for group in groups:
        if group in selections:
            continue
        if available_index < len(available):
            source = available[available_index]
            available_index += 1
        else:
            source = pool[repeat_index % len(pool)]
            repeat_index += 1
        focus_x, focus_y = focus_for_source(source)
        selections[group] = (source, focus_x, focus_y)
    return selections


def render_textures(
    source_root: Path,
    asset_root: Path,
    stage: Path,
    photo_count: int,
) -> tuple[list[dict], list[Path]]:
    original_root = asset_root / "all-textures"
    raw_root = asset_root / "all-textures-raw"
    originals = sorted(original_root.rglob("*.xbm"))
    groups = sorted({depot_group(str(path.relative_to(original_root))) for path in originals})
    pool = source_files(source_root, photo_count)
    selections = assign_sources(groups, pool)

    count_by_group: dict[str, int] = defaultdict(int)
    representative: dict[str, Path] = {}
    largest_area: dict[str, int] = defaultdict(int)
    for index, original in enumerate(originals, 1):
        relative = original.relative_to(original_root)
        raw = (raw_root / relative).with_suffix(".png")
        if not raw.is_file():
            raise FileNotFoundError(f"Missing uncooked PNG: {raw}")
        destination_xbm = stage / relative
        destination_png = destination_xbm.with_suffix(".png")
        destination_xbm.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(original, destination_xbm)
        group = depot_group(str(relative))
        source, focus_x, focus_y = selections[group]
        with Image.open(raw) as template, Image.open(source) as photograph:
            # Block-compressed XBM imports require even edges. A few CARE 720p
            # sources have an odd height, so pad that edge by one pixel.
            size = tuple(value + (value % 2) for value in template.size)
            oriented = ImageOps.exif_transpose(photograph).convert("RGB")
            fitted = ImageOps.fit(
                oriented,
                size,
                method=Image.Resampling.LANCZOS,
                centering=(focus_x, focus_y),
            )
            fitted.save(destination_png, format="PNG", optimize=False)
        count_by_group[group] += 1
        area = size[0] * size[1]
        if area > largest_area[group]:
            largest_area[group] = area
            representative[group] = destination_png
        if index % 50 == 0 or index == len(originals):
            print(f"Rendered {index}/{len(originals)} textures", flush=True)

    report = []
    for group in groups:
        source, focus_x, focus_y = selections[group]
        report.append(
            {
                "group": group,
                "source": str(source.relative_to(source_root)),
                "focus_x": focus_x,
                "focus_y": focus_y,
                "textures": count_by_group[group],
            }
        )
    return report, [representative[group] for group in groups]


def write_csv(path: Path, rows: list[dict]) -> None:
    if not rows:
        return
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def make_contact_sheet(paths: list[Path], destination: Path) -> None:
    columns, cell_w, cell_h, label_h = 8, 240, 170, 24
    rows = math.ceil(len(paths) / columns)
    sheet = Image.new("RGB", (columns * cell_w, rows * cell_h), (22, 22, 24))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for index, path in enumerate(paths):
        x = (index % columns) * cell_w
        y = (index // columns) * cell_h
        with Image.open(path) as image:
            thumb = ImageOps.contain(image.convert("RGB"), (cell_w - 8, cell_h - label_h - 8))
        px = x + (cell_w - thumb.width) // 2
        py = y + (cell_h - label_h - thumb.height) // 2
        sheet.paste(thumb, (px, py))
        draw.text((x + 5, y + cell_h - label_h + 4), depot_group(str(path)), fill="white", font=font)
    sheet.save(destination, format="PNG")


def main() -> int:
    args = parse_args()
    required = [
        args.source_root,
        args.cli,
        args.asset_root / "all-atlases",
        args.asset_root / "all-atlases-json",
        args.asset_root / "all-widgets",
        args.asset_root / "all-widgets-json",
        args.asset_root / "all-textures",
        args.asset_root / "all-textures-raw",
    ]
    for path in required:
        if not path.exists():
            raise FileNotFoundError(f"Required path is missing: {path}")
    if args.build_root.exists() and not args.resume_stage:
        raise FileExistsError(f"Build root already exists: {args.build_root}")

    stage = args.build_root / args.archive_name.removesuffix(".archive")
    modified_json = args.build_root / "modified-json"
    binary_flat = args.build_root / "deserialized"
    archives = args.build_root / "archives"
    for path in (stage, modified_json, binary_flat, archives):
        path.mkdir(parents=True, exist_ok=True)

    if args.resume_stage:
        if not stage.is_dir():
            raise FileNotFoundError(f"Resume stage is missing: {stage}")
        atlas_count = len(list(stage.rglob("*.inkatlas")))
        widget_count = len(list(stage.rglob("*.inkwidget")))
        if not atlas_count or not widget_count:
            raise RuntimeError("Resume stage has no prepared INK resources")
        atlas_report: list[dict] = []
        widget_report: list[dict] = []
    else:
        print("Preparing atlas definitions", flush=True)
        atlas_infos, atlas_report = prepare_atlases(args.asset_root, modified_json)
        print("Simplifying advert widgets", flush=True)
        widget_report, widget_originals = prepare_widgets(
            args.asset_root, modified_json, atlas_infos
        )
        print("Deserializing modified INK resources", flush=True)
        run([args.cli, "convert", "deserialize", modified_json, "-o", binary_flat, "-v", "Minimal"])
        atlas_count, widget_count = copy_deserialized(
            binary_flat, stage, args.asset_root, atlas_infos, widget_originals
        )

    print("Rendering all world-advert texture slots", flush=True)
    texture_report, representatives = render_textures(
        args.source_root, args.asset_root, stage, args.photo_count
    )
    write_csv(args.build_root / "atlas-manifest.csv", atlas_report)
    write_csv(args.build_root / "widget-manifest.csv", widget_report)
    write_csv(args.build_root / "texture-manifest.csv", texture_report)
    make_contact_sheet(representatives, args.build_root / "preview-all-groups.png")

    print("Importing PNG buffers into the stock XBM containers", flush=True)
    imported = import_texture_buffers(args.cli, stage, args.import_workers)
    if imported != args.expected_textures:
        raise RuntimeError(
            f"Expected to import {args.expected_textures} textures, imported {imported}"
        )
    for png in stage.rglob("*.png"):
        png.unlink()

    print("Packing final archive", flush=True)
    run([args.cli, "pack", stage, "-o", archives, "-v", "Minimal"])
    archive = archives / args.archive_name
    if not archive.is_file():
        raise RuntimeError(f"Expected archive was not created: {archive}")

    info = run(
        [args.cli, "archiveinfo", archive, "--list", "--regex", r"(?i)\.(xbm|inkatlas|inkwidget)$", "-v", "Minimal"],
        capture=True,
    )
    resource_suffixes = {".xbm", ".inkatlas", ".inkwidget"}
    expected_resources = {
        norm_depot(str(path.relative_to(stage)))
        for path in stage.rglob("*")
        if path.is_file() and path.suffix.lower() in resource_suffixes
    }
    archive_resource_list = [
        norm_depot(line.strip())
        for line in info.stdout.splitlines()
        if line.strip().lower().startswith(("base\\", "ads_extended\\"))
    ]
    archive_resources = set(archive_resource_list)
    expected = args.expected_textures + atlas_count + widget_count
    if len(expected_resources) != expected:
        raise RuntimeError(
            f"Stage validation failed: expected {expected} resources, "
            f"found {len(expected_resources)}"
        )
    if len(archive_resource_list) != len(archive_resources):
        raise RuntimeError("Archive validation failed: duplicate depot paths were listed")
    if archive_resources != expected_resources:
        missing = sorted(expected_resources - archive_resources)
        unexpected = sorted(archive_resources - expected_resources)
        raise RuntimeError(
            "Archive depot paths differ from the stage; "
            f"missing={missing[:10]}, unexpected={unexpected[:10]}"
        )

    installed = None
    if not args.no_install:
        args.install_dir.mkdir(parents=True, exist_ok=True)
        installed = args.install_dir / args.archive_name
        temporary = installed.with_suffix(installed.suffix + ".tmp")
        shutil.copy2(archive, temporary)
        temporary.replace(installed)

    summary = {
        "archive": str(archive),
        "installed": str(installed) if installed else None,
        "textures": args.expected_textures,
        "atlases": atlas_count,
        "widgets": widget_count,
        "resources": len(archive_resources),
        "groups": len(texture_report),
        "distinct_source_photos": args.photo_count,
        "preview": str(args.build_root / "preview-all-groups.png"),
    }
    with (args.build_root / "build-summary.json").open("w", encoding="utf-8") as handle:
        json.dump(summary, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as error:
        print(f"Command failed with exit code {error.returncode}: {error.cmd}", file=sys.stderr)
        raise
