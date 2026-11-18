#!/usr/bin/env python3
"""Tiles the pictures saved by `REVIEW=1 flutter test test/layout` into one
sheet per screen, so a person can look at every size and text scale together.

Reads build/review/<screen>/<size>-<scale>x.png and writes
build/review/sheets/<screen>.png plus build/review/sheets/index.png.
Needs Pillow. Run from the repository root.
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path("build/review")
OUT = ROOT / "sheets"
ORDER = ["small-phone-1.0x", "small-phone-1.3x", "small-phone-2.0x", "phone-1.0x", "phone-2.0x", "tablet-1.0x", "tablet-2.0x", "phone-dark-1.0x", "phone-dark-2.0x", "small-phone-dark-1.0x", "small-phone-dark-2.0x"]
HEIGHT = 700


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    sheets = []
    for folder in sorted(p for p in ROOT.iterdir() if p.is_dir() and p.name != "sheets"):
        tiles = []
        for name in ORDER:
            f = folder / f"{name}.png"
            if f.exists():
                im = Image.open(f).convert("RGB")
                im = im.resize((int(im.width * HEIGHT / im.height), HEIGHT), Image.LANCZOS)
                tiles.append((name, im))
        if not tiles:
            continue
        width = sum(i.width for _, i in tiles) + 12 * (len(tiles) + 1)
        sheet = Image.new("RGB", (width, HEIGHT + 56), "white")
        draw, x = ImageDraw.Draw(sheet), 12
        draw.text((12, 6), folder.name, fill="black")
        for name, im in tiles:
            draw.text((x, 30), name, fill="gray")
            sheet.paste(im, (x, 50))
            x += im.width + 12
        path = OUT / f"{folder.name}.png"
        sheet.save(path)
        sheets.append(path)
    print(f"{len(sheets)} sheets written to {OUT}")


if __name__ == "__main__":
    main()
