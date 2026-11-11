#!/usr/bin/env python3
"""One-off conversion of legacy Android resources into Flutter assets.

- PNG/JPG art      -> WebP under assets/images/
- vector drawables -> SVG under assets/images/
- voice clips      -> AAC remuxed (not re-encoded) into .m4a under assets/audio/voice/en/
- music, effects, fonts copied under assets/

Needs Pillow and ffmpeg. Run from the repository root:  python3 tool/convert_assets.py
"""
import re
import shutil
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "legacy/android-native/app/src/main/res"
ASSETS = ROOT / "assets"
A = "{http://schemas.android.com/apk/res/android}"

IMAGES = {
    # legacy drawable -> (asset path, max edge in px)
    **{f"mainscreen_outfit1_fullbody_{e}.png": (f"character/classic/{e}.webp", 1000)
       for e in ("happy", "hello", "sad", "tired")},
    **{f"mainscreen_outfit2_fullbody_{e}.png": (f"character/blue_bao/{e}.webp", 1000)
       for e in ("happy", "hello", "sad", "tired")},
    **{f"{m}face_default.png": (f"moods/{m}.webp", 384)
       for m in ("happy", "okay", "sad", "anxious", "tired")},
    "baobao_main_default.png": ("brand/baobao.webp", 575),
    "bao_bao_loadingscreen.png": ("brand/loading.webp", 545),
    "baobaotextlogo.png": ("brand/wordmark.webp", 960),
    "moesoft_nobg.png": ("brand/studio.webp", 707),
    "applogo.jpg": ("brand/app_icon.png", 1024),
}
VECTORS = {
    "main_bamboo_background": "backgrounds/bamboo.svg",
    "bg_bamboo_clouds": "backgrounds/bamboo_clouds.svg",
    "bg_bamboo_plum": "backgrounds/bamboo_plum.svg",
    "bamboo_claw": "claw/claw.svg",
    "ic_claw_machine_logo": "claw/logo.svg",
}
MUSIC = {
    "main_bgm_kakushigoto.mp3": "music/kakushigoto.mp3",
    "main_bgm_little.mp3": "music/little.mp3",
    "main_bgm_ordinary_days.mp3": "music/ordinary_days.mp3",
    "shop_bgm.mp3": "music/shop.mp3",
    "clawmachine_bgm.mp3": "music/claw_machine.mp3",
    "click_sfx.mp3": "sfx/click.mp3",
}
FONTS = {"regular": "Regular", "light": "Light", "medium": "Medium",
         "semibold": "SemiBold", "bold": "Bold"}


def colours() -> dict[str, str]:
    root = ET.parse(RES / "values/colors.xml").getroot()
    return {c.get("name"): c.text.strip() for c in root.findall("color")}


def paint(value: str, palette: dict[str, str]) -> tuple[str, float]:
    """Android colour (#RGB, #RRGGBB, #AARRGGBB or @color/x) -> (#rrggbb, opacity)."""
    if value.startswith("@color/"):
        value = palette[value.split("/")[1]]
    value = value.lstrip("#")
    if len(value) == 8:
        return "#" + value[2:].lower(), int(value[:2], 16) / 255
    return "#" + value.lower(), 1.0


def convert_node(node, palette, depth=1) -> list[str]:
    pad = "  " * depth
    out = []
    for child in node:
        if child.tag == "path":
            attrs = [f'd="{child.get(A + "pathData")}"']
            fill = child.get(A + "fillColor")
            if fill:
                colour, alpha = paint(fill, palette)
                alpha *= float(child.get(A + "fillAlpha", "1"))
                attrs.append(f'fill="{colour}"')
                if alpha < 1:
                    attrs.append(f'fill-opacity="{alpha:.3g}"')
            else:
                attrs.append('fill="none"')
            stroke = child.get(A + "strokeColor")
            if stroke:
                colour, alpha = paint(stroke, palette)
                alpha *= float(child.get(A + "strokeAlpha", "1"))
                attrs.append(f'stroke="{colour}" stroke-width="{child.get(A + "strokeWidth", "1")}"')
                if alpha < 1:
                    attrs.append(f'stroke-opacity="{alpha:.3g}"')
                if child.get(A + "strokeLineCap"):
                    attrs.append(f'stroke-linecap="{child.get(A + "strokeLineCap")}"')
            out.append(f"{pad}<path {' '.join(attrs)}/>")
        elif child.tag == "group":
            tx, ty = child.get(A + "translateX", "0"), child.get(A + "translateY", "0")
            sx, sy = child.get(A + "scaleX", "1"), child.get(A + "scaleY", "1")
            px, py = child.get(A + "pivotX", "0"), child.get(A + "pivotY", "0")
            rot = child.get(A + "rotation", "0")
            # Android applies: translate(pivot + translate) . rotate . scale . translate(-pivot)
            transform = (f"translate({float(px) + float(tx):g} {float(py) + float(ty):g}) "
                         f"rotate({rot}) scale({sx} {sy}) translate({-float(px):g} {-float(py):g})")
            out.append(f'{pad}<g transform="{transform}">')
            out.extend(convert_node(child, palette, depth + 1))
            out.append(f"{pad}</g>")
    return out


def vector_to_svg(src: Path, dst: Path, palette) -> None:
    root = ET.parse(src).getroot()
    w, h = root.get(A + "viewportWidth"), root.get(A + "viewportHeight")
    lines = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">']
    lines += convert_node(root, palette)
    lines.append("</svg>")
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    palette = colours()

    for name, (target, edge) in IMAGES.items():
        image = Image.open(RES / "drawable" / name)
        image.thumbnail((edge, edge), Image.LANCZOS)
        dst = ASSETS / "images" / target
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.suffix == ".png":
            image.save(dst, optimize=True)
        else:
            image.save(dst, "WEBP", quality=90, method=6)

    for name, target in VECTORS.items():
        vector_to_svg(RES / "drawable" / f"{name}.xml", ASSETS / "images" / target, palette)
    for src in sorted((RES / "drawable").glob("ic_*_bamboo.xml")) + [RES / "drawable/ic_claw_nav.xml"]:
        name = re.sub(r"^ic_|_bamboo$", "", src.stem)
        vector_to_svg(src, ASSETS / "images/icons" / f"{name}.svg", palette)

    voice = ASSETS / "audio/voice/en"
    voice.mkdir(parents=True, exist_ok=True)
    for src in sorted((RES / "raw").glob("*.aac")):
        subprocess.run(
            ["ffmpeg", "-loglevel", "error", "-y", "-i", str(src), "-c", "copy",
             "-bsf:a", "aac_adtstoasc", "-movflags", "+faststart", str(voice / f"{src.stem}.m4a")],
            check=True)

    for name, target in MUSIC.items():
        dst = ASSETS / "audio" / target
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(RES / "raw" / name, dst)

    (ASSETS / "fonts").mkdir(parents=True, exist_ok=True)
    for legacy, weight in FONTS.items():
        shutil.copyfile(RES / "font" / f"quicksand_{legacy}.ttf", ASSETS / "fonts" / f"Quicksand-{weight}.ttf")

    print("assets written to", ASSETS)


if __name__ == "__main__":
    main()
