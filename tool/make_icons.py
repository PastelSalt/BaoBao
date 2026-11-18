#!/usr/bin/env python3
"""Builds the launcher icons and splash images from the panda cut-out.

Source: assets/images/brand/baobao.webp (the waving panda, transparent).

Android: an adaptive icon (background, foreground, and a single-colour
monochrome layer for Android 13 themed icons), the legacy square icon, and
the pre-Android-12 splash image.
iOS: full-bleed icons (iOS applies its own rounded mask) and launch images.

Run from the repository root:  python3 tool/make_icons.py
"""
import json
import math
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "android/app/src/main/res"
IOS = ROOT / "ios/Runner/Assets.xcassets"
CREAM = (246, 246, 219)

panda = Image.open(ROOT / "assets/images/brand/baobao.webp").convert("RGBA")
panda = panda.crop(panda.getchannel("A").getbbox())


def fit(image, box_height):
    w = round(image.width * box_height / image.height)
    return image.resize((w, box_height), Image.LANCZOS)


def background(size):
    """Soft bamboo-green glow with faint stalks."""
    s = size
    im = Image.new("RGB", (s, s), (143, 196, 111))
    px = im.load()
    cx, cy = s * 0.5, s * 0.42
    for y in range(s):
        for x in range(s):
            d = min(1.0, math.hypot(x - cx, y - cy) / (s * 0.72))
            t = d * d
            px[x, y] = (round(214 + (140 - 214) * t), round(236 + (190 - 236) * t), round(178 + (108 - 178) * t))
    draw = ImageDraw.Draw(im, "RGBA")
    for fx, w, a in [(0.12, 0.05, 70), (0.28, 0.03, 45), (0.74, 0.03, 45), (0.9, 0.06, 80)]:
        x0 = s * fx
        draw.rounded_rectangle([x0, -s * 0.1, x0 + s * w, s * 1.1], radius=s * w / 2, fill=(86, 140, 70, a))
        for ny in (0.2, 0.46, 0.7, 0.92):
            draw.rectangle([x0 - 1, s * ny, x0 + s * w + 1, s * ny + s * 0.012], fill=(60, 105, 52, a))
    return im


def foreground(size, height_fraction=0.58):
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    p = fit(panda, round(size * height_fraction))
    # Shadow under the panda, so it lifts off the green.
    shadow = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    ellipse = ImageDraw.Draw(shadow)
    ex, ey = size / 2, size / 2 + p.height / 2 - size * 0.01
    ellipse.ellipse([ex - p.width * 0.36, ey - size * 0.025, ex + p.width * 0.36, ey + size * 0.03], fill=(40, 70, 35, 90))
    layer.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(size * 0.012)))
    layer.alpha_composite(p, ((size - p.width) // 2, (size - p.height) // 2))
    return layer


def monochrome(size):
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    p = fit(panda, round(size * 0.58))
    silhouette = Image.new("RGBA", p.size, (0, 0, 0, 255))
    silhouette.putalpha(p.getchannel("A"))
    layer.alpha_composite(silhouette, ((size - p.width) // 2, (size - p.height) // 2))
    return layer


def rounded(im, radius_fraction=0.2):
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, im.width - 1, im.height - 1], radius=im.width * radius_fraction, fill=255)
    out = im.convert("RGBA")
    out.putalpha(mask)
    return out


def save(im, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)


def android_icons():
    layer_sizes = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}
    legacy_sizes = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    big_bg, big_fg = background(432), foreground(432)
    for density, size in layer_sizes.items():
        folder = RES / f"mipmap-{density}"
        save(big_bg.resize((size, size), Image.LANCZOS), folder / "ic_launcher_background.png")
        save(big_fg.resize((size, size), Image.LANCZOS), folder / "ic_launcher_foreground.png")
        save(monochrome(432).resize((size, size), Image.LANCZOS), folder / "ic_launcher_monochrome.png")
        legacy = big_bg.convert("RGBA")
        legacy.alpha_composite(foreground(432, 0.7))
        legacy = rounded(legacy.resize((legacy_sizes[density],) * 2, Image.LANCZOS))
        save(legacy, folder / "ic_launcher.png")
    adaptive = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
        "</adaptive-icon>\n"
    )
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        (RES / "mipmap-anydpi-v26").mkdir(parents=True, exist_ok=True)
        (RES / "mipmap-anydpi-v26" / name).write_text(adaptive, encoding="utf-8")


def android_splash():
    heights = {"mdpi": 150, "hdpi": 225, "xhdpi": 300, "xxhdpi": 450, "xxxhdpi": 600}
    for density, h in heights.items():
        save(fit(panda, h), RES / f"drawable-{density}" / "splash.png")
    # Replace what the old generator left behind with colours that follow the theme.
    # (values-v31 styles point the Android 12 splash at the adaptive icon
    # foreground and at @color/splash_background, so those are not touched here.)
    for stale in list(RES.glob("drawable*/android12splash.png")) + list(RES.glob("drawable*/background.png")):
        stale.unlink()
    for folder in RES.glob("drawable-night-*"):
        if not any(folder.iterdir()):
            folder.rmdir()
    launch = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<layer-list xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <item><color android:color="@color/splash_background"/></item>\n'
        '    <item><bitmap android:gravity="center" android:src="@drawable/splash"/></item>\n'
        "</layer-list>\n"
    )
    for folder in ("drawable", "drawable-v21"):
        (RES / folder / "launch_background.xml").write_text(launch, encoding="utf-8")
    (RES / "values/colors.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="splash_background">#F6F6DB</color>\n</resources>\n',
        encoding="utf-8")
    (RES / "values-night").mkdir(exist_ok=True)
    (RES / "values-night/colors.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="splash_background">#16231A</color>\n</resources>\n',
        encoding="utf-8")


def ios_icons():
    base = IOS / "AppIcon.appiconset"
    contents = json.loads((base / "Contents.json").read_text())
    big = background(1024).convert("RGBA")
    big.alpha_composite(foreground(1024, 0.66))
    big = big.convert("RGB")
    for entry in contents["images"]:
        if "filename" not in entry:
            continue
        px = round(float(entry["size"].split("x")[0]) * int(entry["scale"][0]))
        save(big.resize((px, px), Image.LANCZOS), base / entry["filename"])
    launch = IOS / "LaunchImage.imageset"
    for f in launch.glob("*.png"):
        with Image.open(f) as existing:
            w, h = existing.size
        canvas = Image.new("RGBA", (w, h), CREAM + (255,))
        p = fit(panda, round(min(w, h) * 0.3))
        canvas.alpha_composite(p, ((w - p.width) // 2, (h - p.height) // 2))
        canvas.convert("RGB").save(f)


if __name__ == "__main__":
    android_icons()
    android_splash()
    ios_icons()
    print("icons and splash written")
