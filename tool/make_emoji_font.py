#!/usr/bin/env python3
"""Keeps every character in BaoBao's text drawable on every phone.

Quicksand (the app font) has letters, digits and punctuation but no emoji.
Phones draw emoji from their own system font, and older Android versions lack
newer emoji, which then show as empty boxes. So the app bundles a small emoji
font, `assets/fonts/BaoBaoEmoji.ttf`, containing only the emoji its text uses.

This script:
  1. collects every character used in assets/content/**/*.json and lib/l10n/*.arb;
  2. checks each is covered by Quicksand or by the system Noto Color Emoji font;
  3. writes the subset font (unless --check is given).

  python3 tool/make_emoji_font.py           rebuild the font
  python3 tool/make_emoji_font.py --check   fail if any character is uncovered,
                                            or the bundled font is out of date

The emoji come from Noto Color Emoji (SIL Open Font License 1.1 for the font,
Apache 2.0 for the images). Needs fonttools and the font installed at
/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf (apt: fonts-noto-color-emoji).
"""
import json
import sys
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parent.parent
SOURCE = Path("/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf")
OUT = ROOT / "assets/fonts/BaoBaoEmoji.ttf"
LATIN = ROOT / "assets/fonts/Quicksand-Medium.ttf"
JOINERS = {0x200D, 0xFE0F, 0xFE0E, 0x20E3}


def used_characters() -> set[int]:
    chars: set[int] = set()
    files = list((ROOT / "assets/content").rglob("*.json")) + list((ROOT / "lib/l10n").glob("*.arb"))
    for f in files:
        chars |= {ord(c) for c in f.read_text(encoding="utf-8")}
    return {c for c in chars if c > 0x7F or c in (0x20,)} - {0x20}


def main(check: bool) -> int:
    used = used_characters()
    latin = set(TTFont(LATIN).getBestCmap())
    needs_emoji = {c for c in used if c not in latin and c not in JOINERS}

    emoji_cmap = set(TTFont(SOURCE).getBestCmap()) if SOURCE.exists() else set()
    uncovered = sorted(c for c in needs_emoji if c not in emoji_cmap) if emoji_cmap else []
    if uncovered:
        print("Characters used in the text that no bundled font can draw:")
        for c in uncovered:
            print(f"  U+{c:04X} {chr(c)!r}")
        print("Replace them in the content, or add a font that has them.")
        return 1

    wanted = sorted(needs_emoji | JOINERS)
    print(f"{len(used)} non-ASCII characters used; {len(needs_emoji)} come from the emoji font")

    if not SOURCE.exists():
        print("Noto Color Emoji is not installed here; cannot rebuild the font.")
        return 1 if check and not OUT.exists() else 0

    options = subset.Options()
    options.layout_features = ["*"]
    options.glyph_names = False
    options.notdef_outline = True
    options.name_IDs = ["*"]
    font = subset.load_font(str(SOURCE), options)
    sub = subset.Subsetter(options)
    sub.populate(unicodes=wanted)
    sub.subset(font)

    if check:
        have = set(TTFont(OUT).getBestCmap()) if OUT.exists() else set()
        missing = [c for c in needs_emoji if c not in have]
        if missing:
            print("The bundled emoji font is out of date; missing:")
            for c in sorted(missing):
                print(f"  U+{c:04X} {chr(c)!r}")
            print("Run: python3 tool/make_emoji_font.py")
            return 1
        print("Emoji font is up to date.")
        return 0

    OUT.parent.mkdir(parents=True, exist_ok=True)
    subset.save_font(font, str(OUT), options)
    print(f"wrote {OUT} ({OUT.stat().st_size // 1024} KB)")
    return 0


if __name__ == "__main__":
    sys.exit(main("--check" in sys.argv))
