#!/usr/bin/env python3
"""Draws BaoBao's three home backgrounds, each in a day and a night version.

Output: assets/images/backgrounds/<name>.svg and <name>_night.svg, 400x800,
meant to be drawn with BoxFit.cover. Deterministic: the same script always
produces the same files. Only features flutter_svg supports are used
(gradients, shapes, groups, opacity), so there are no filters or masks.

Run from the repository root:  python3 tool/make_backgrounds.py
"""
import math
import random
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "assets/images/backgrounds"
W, H = 400, 800


class Scene:
    def __init__(self, seed):
        self.rng = random.Random(seed)
        self.defs, self.body = [], []

    def add(self, s):
        self.body.append(s)

    def gradient(self, name, stops, *, x1=0, y1=0, x2=0, y2=1):
        s = "".join(f'<stop offset="{o}" stop-color="{c}" stop-opacity="{a}"/>' for o, c, a in stops)
        self.defs.append(f'<linearGradient id="{name}" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}">{s}</linearGradient>')

    def radial(self, name, color, inner=0.9, outer=0.0):
        self.defs.append(
            f'<radialGradient id="{name}"><stop offset="0" stop-color="{color}" stop-opacity="{inner}"/>'
            f'<stop offset="1" stop-color="{color}" stop-opacity="{outer}"/></radialGradient>')

    def svg(self):
        return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}">\n<defs>{"".join(self.defs)}</defs>\n'
                + "\n".join(self.body) + "\n</svg>\n")


def leaf(s, x, y, length, angle, color, opacity):
    s.add(f'<path transform="translate({x:.1f} {y:.1f}) rotate({angle:.0f})" '
          f'd="M0,0 Q{length*0.5:.1f},{-length*0.30:.1f} {length:.1f},0 Q{length*0.5:.1f},{length*0.20:.1f} 0,0Z" '
          f'fill="{color}" fill-opacity="{opacity}"/>')


def stalk(s, x, width, body, shade, node, opacity, leaves=None):
    r = s.rng
    s.add(f'<g opacity="{opacity}">')
    s.add(f'<rect x="{x - width/2:.1f}" y="-10" width="{width:.1f}" height="{H + 20}" rx="{width/2:.1f}" fill="{body}"/>')
    s.add(f'<rect x="{x - width/2 + width*0.16:.1f}" y="-10" width="{width*0.2:.1f}" height="{H + 20}" rx="{width*0.1:.1f}" fill="{shade}" fill-opacity="0.45"/>')
    y = r.uniform(30, 110)
    while y < H:
        s.add(f'<rect x="{x - width/2 - 1.5:.1f}" y="{y:.1f}" width="{width + 3:.1f}" height="{max(3.0, width*0.16):.1f}" rx="{width*0.08:.1f}" fill="{node}" fill-opacity="0.7"/>')
        if leaves and r.random() < 0.5:
            side = r.choice([-1, 1])
            leaf(s, x + side * width / 2, y, r.uniform(26, 46) * (width / 16) ** 0.4, (-35 if side > 0 else 215) + r.uniform(-18, 18), leaves, 0.85)
        y += r.uniform(80, 150) * (width / 16) ** 0.5
    s.add('</g>')


def stalks(s, p, layers):
    """layers: (count, width range, opacity, region) from far to near."""
    for count, (w0, w1), opacity, (xa, xb) in layers:
        xs = sorted(s.rng.uniform(xa, xb) for _ in range(count))
        for x in xs:
            stalk(s, x, s.rng.uniform(w0, w1), p["stalk"], p["stalk_shade"], p["node"], opacity, p["leaf"])


def cloud(s, cx, cy, size, color, opacity):
    puffs = [(-0.9, 0.15, 0.55), (-0.35, -0.12, 0.75), (0.25, -0.05, 0.7), (0.85, 0.12, 0.5), (0.0, 0.2, 0.9)]
    s.add(f'<g opacity="{opacity}">')
    for dx, dy, r in puffs:
        s.add(f'<ellipse cx="{cx + dx*size:.1f}" cy="{cy + dy*size*0.5:.1f}" rx="{r*size*0.62:.1f}" ry="{r*size*0.36:.1f}" fill="{color}"/>')
    s.add('</g>')


def stars(s, n, color, region=(0, H * 0.55)):
    for _ in range(n):
        x, y, r = s.rng.uniform(0, W), s.rng.uniform(*region), s.rng.uniform(0.6, 1.8)
        s.add(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{r:.1f}" fill="{color}" fill-opacity="{s.rng.uniform(0.35, 0.9):.2f}"/>')


def glow(s, name, cx, cy, r, core):
    s.add(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#{name})"/>')
    s.add(f'<circle cx="{cx}" cy="{cy}" r="{r*0.2:.1f}" fill="{core}" fill-opacity="0.95"/>')


def fireflies(s, n, color):
    for i in range(n):
        x, y = s.rng.uniform(20, W - 20), s.rng.uniform(H * 0.45, H * 0.92)
        s.add(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="9" fill="url(#ff)"/>')
        s.add(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="1.8" fill="{color}"/>')


def mist(s, color, top, strength):
    s.gradient("mist", [(0, color, 0), (1, color, strength)])
    s.add(f'<rect x="0" y="{top}" width="{W}" height="{H - top}" fill="url(#mist)"/>')


# ---------------------------------------------------------------- scenes --

def grove(night):
    s = Scene(11)
    if night:
        p = dict(sky=[(0, "#14231A", 1), (0.6, "#1F3526", 1), (1, "#2A4531", 1)], stalk="#35603F", stalk_shade="#6FA37C",
                 node="#1B3322", leaf="#4C8A58", glow="#DDF2D0", mist="#2A4531")
    else:
        p = dict(sky=[(0, "#E4F3CF", 1), (0.55, "#F2F5D8", 1), (1, "#F6F6DB", 1)], stalk="#A9D18B", stalk_shade="#E8F5D8",
                 node="#7DA860", leaf="#8CC172", glow="#FFF8C9", mist="#F6F6DB")
    s.gradient("sky", p["sky"])
    s.add(f'<rect width="{W}" height="{H}" fill="url(#sky)"/>')
    s.radial("glow", p["glow"], 0.85 if not night else 0.55)
    s.radial("ff", "#F4F7B0", 0.9)
    glow(s, "glow", 310, 150, 190, "#FFFFFF" if not night else "#EAF4E0")
    if night:
        stars(s, 40, "#DDF2D0")
    stalks(s, p, [(7, (8, 12), 0.35, (10, 390)), (5, (14, 19), 0.55, (0, 400)),
                  (2, (30, 40), 0.85, (-6, 40)), (2, (30, 40), 0.85, (360, 406))])
    mist(s, p["mist"], 430, 0.75)
    if night:
        fireflies(s, 16, "#F7F9C0")
    else:
        for _ in range(7):
            leaf(s, s.rng.uniform(20, 380), s.rng.uniform(80, 760), s.rng.uniform(14, 24), s.rng.uniform(0, 360), p["leaf"], 0.55)
    return s


def clouds(night):
    s = Scene(23)
    if night:
        p = dict(sky=[(0, "#18213B", 1), (0.5, "#2D3560", 1), (1, "#4A4A73", 1)], cloud="#6B6F9E", cloud2="#8C8FBB",
                 stalk="#3B5C6B", stalk_shade="#7FA6B6", node="#233844", leaf="#5C8C9A", glow="#E8EEFF", mist="#4A4A73")
    else:
        p = dict(sky=[(0, "#C9E6F5", 1), (0.45, "#E3EEF2", 1), (0.78, "#FBE7D2", 1), (1, "#FFF1DE", 1)], cloud="#FFFFFF",
                 cloud2="#FDF3E8", stalk="#9CC9A7", stalk_shade="#E5F3E8", node="#6E9E7C", leaf="#7EB48D", glow="#FFE9B8", mist="#FFF1DE")
    s.gradient("sky", p["sky"])
    s.add(f'<rect width="{W}" height="{H}" fill="url(#sky)"/>')
    s.radial("glow", p["glow"], 0.9 if not night else 0.5)
    glow(s, "glow", 90, 540 if not night else 140, 230, "#FFFFFF" if not night else "#F2F5FF")
    if night:
        stars(s, 55, "#E8EEFF", (0, 360))
    for cx, cy, size, op in [(300, 110, 150, 0.55), (90, 230, 120, 0.7), (330, 360, 170, 0.6), (60, 500, 140, 0.8), (260, 600, 190, 0.85)]:
        cloud(s, cx, cy, size, p["cloud"], op)
        cloud(s, cx + 10, cy + 12, size * 0.8, p["cloud2"], op * 0.8)
    stalks(s, p, [(5, (8, 11), 0.35, (10, 390)), (3, (14, 18), 0.5, (0, 400)), (2, (28, 38), 0.8, (-4, 36)), (2, (28, 38), 0.8, (364, 404))])
    mist(s, p["mist"], 300, 0.85)
    return s


def blossom(s, x, y, r, color, center, opacity=1.0, tilt=0):
    s.add(f'<g opacity="{opacity}" transform="translate({x:.1f} {y:.1f}) rotate({tilt})">')
    for k in range(5):
        a = math.radians(72 * k - 90)
        s.add(f'<circle cx="{r*0.56*math.cos(a):.2f}" cy="{r*0.56*math.sin(a):.2f}" r="{r*0.5:.2f}" fill="{color}"/>')
    s.add(f'<circle r="{r*0.24:.2f}" fill="{center}"/>')
    for k in range(6):
        a = math.radians(60 * k + 15)
        s.add(f'<circle cx="{r*0.36*math.cos(a):.2f}" cy="{r*0.36*math.sin(a):.2f}" r="{r*0.05:.2f}" fill="{center}"/>')
    s.add('</g>')


def branch(s, d, widths, color):
    for w in widths:
        s.add(f'<path d="{d}" fill="none" stroke="{color}" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"/>')


def plum(night):
    s = Scene(37)
    if night:
        p = dict(sky=[(0, "#241A2E", 1), (0.55, "#382748", 1), (1, "#4A3558", 1)], bark="#5A4252", bark_hi="#7A5D6E",
                 pink="#E58FAE", pink2="#F6B9CF", centre="#FFD98A", stalk="#3F3552", stalk_shade="#6F628C", node="#2B2238", leaf="#5B4C78",
                 glow="#F2DFFF", mist="#4A3558")
    else:
        p = dict(sky=[(0, "#F9DCD6", 1), (0.5, "#FBEBDD", 1), (1, "#F6F1DF", 1)], bark="#7A5C4A", bark_hi="#A58168",
                 pink="#F29DB5", pink2="#FAC9D8", centre="#F7C948", stalk="#B9D5A8", stalk_shade="#EEF6E4", node="#8FB27C", leaf="#9DC48A",
                 glow="#FFE3C8", mist="#F6F1DF")
    s.gradient("sky", p["sky"])
    s.add(f'<rect width="{W}" height="{H}" fill="url(#sky)"/>')
    s.radial("glow", p["glow"], 0.8 if not night else 0.55)
    glow(s, "glow", 80, 120, 170, "#FFFFFF" if not night else "#F6EEFF")
    if night:
        stars(s, 35, "#F2DFFF", (0, 360))
    stalks(s, p, [(5, (8, 11), 0.3, (10, 390)), (3, (13, 17), 0.42, (0, 400))])
    mist(s, p["mist"], 520, 0.6)

    # Two branches entering from the right edge, drawn as tapering strokes.
    branches = [
        ("M430,70 C350,85 300,60 235,105 C200,130 170,128 135,160", [13, 9, 5], [(318, 78), (265, 96), (190, 125), (150, 148)]),
        ("M430,300 C360,320 330,290 270,335 C235,362 215,360 170,395", [15, 10, 6], [(352, 313), (300, 318), (230, 352), (186, 384)]),
        ("M430,560 C375,575 340,548 290,590 C255,620 230,615 195,650", [12, 8, 4], [(365, 565), (318, 568), (262, 606), (212, 640)]),
    ]
    for d, widths, spots in branches:
        branch(s, d, widths, p["bark"])
        branch(s, d, [widths[-1] * 0.5], p["bark_hi"])
        for (x, y) in spots:
            twig_x, twig_y = x + s.rng.uniform(-30, 10), y + s.rng.uniform(-36, -14)
            branch(s, f"M{x},{y} Q{(x + twig_x)/2},{y - 8} {twig_x:.0f},{twig_y:.0f}", [3.5], p["bark"])
            for _ in range(3):
                blossom(s, twig_x + s.rng.uniform(-18, 18), twig_y + s.rng.uniform(-14, 14), s.rng.uniform(11, 17),
                        s.rng.choice([p["pink"], p["pink2"]]), p["centre"], 1.0, s.rng.uniform(0, 72))
            blossom(s, x, y, 15, p["pink2"], p["centre"], 1.0, s.rng.uniform(0, 72))
    # Falling petals.
    for _ in range(22):
        x, y = s.rng.uniform(0, W), s.rng.uniform(40, H - 40)
        s.add(f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{s.rng.uniform(3, 5.5):.1f}" ry="{s.rng.uniform(2, 3.2):.1f}" '
              f'transform="rotate({s.rng.uniform(0, 180):.0f} {x:.1f} {y:.1f})" fill="{p["pink2"]}" fill-opacity="{s.rng.uniform(0.45, 0.9):.2f}"/>')
    return s


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, make in [("bamboo", grove), ("bamboo_clouds", clouds), ("bamboo_plum", plum)]:
        (OUT / f"{name}.svg").write_text(make(False).svg(), encoding="utf-8")
        (OUT / f"{name}_night.svg").write_text(make(True).svg(), encoding="utf-8")
    print("backgrounds written to", OUT)


if __name__ == "__main__":
    main()
