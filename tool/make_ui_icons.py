#!/usr/bin/env python3
"""Writes BaoBao's interface icons as SVG into assets/images/icons/.

One consistent style: 24x24, rounded strokes about 2.2 wide, rounded caps and
joins, drawn in black so the app can tint them. Edit the table below and run
from the repository root:  python3 tool/make_ui_icons.py
"""
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "assets/images/icons"

S = 'fill="none" stroke="#000" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"'
F = 'fill="#000" stroke="#000" stroke-width="1.6" stroke-linejoin="round" stroke-linecap="round"'

ICONS = {
    "back": f'<path {S} d="M15 5 L8 12 L15 19"/>',
    "close": f'<path {S} d="M6 6 L18 18 M18 6 L6 18"/>',
    "add": f'<path {S} d="M12 5 V19 M5 12 H19"/>',
    "check": f'<path {S} d="M5 12.5 L10 17.5 L19 7"/>',
    "settings": f'<path {S} d="M4 7 H20 M4 12 H20 M4 17 H20"/><circle {S} cx="9" cy="7" r="2.4" fill="#fff"/><circle {S} cx="15.5" cy="12" r="2.4" fill="#fff"/><circle {S} cx="8" cy="17" r="2.4" fill="#fff"/>',
    "help": f'<circle {S} cx="12" cy="12" r="8.5"/><circle {S} cx="12" cy="12" r="3.6"/><path {S} d="M6 6 L9.4 9.4 M18 6 L14.6 9.4 M6 18 L9.4 14.6 M18 18 L14.6 14.6"/>',
    "shop": f'<path {S} d="M5 8.5 H19 L18 20 H6 Z"/><path {S} d="M9 8.5 V7.5 a3 3 0 0 1 6 0 V8.5"/>',
    "claw": f'<path {S} d="M12 3 V10"/><path {S} d="M12 10 C8 10 6.2 13 6.2 17 M12 10 C16 10 17.8 13 17.8 17 M12 10 V19"/><circle {F} cx="12" cy="10" r="1.2"/>',
    "sparkle": f'<path {S} d="M12 3 L14 10 L21 12 L14 14 L12 21 L10 14 L3 12 L10 10 Z"/>',
    "cheer": f'<path {S} d="M12 20 C5 14.5 3.2 11.6 3.2 8.6 a4.4 4.4 0 0 1 8.8 -1 a4.4 4.4 0 0 1 8.8 1 c0 3 -1.8 5.9 -8.8 11.4 z"/>',
    "heart": f'<path {F} d="M12 20 C5 14.5 3.2 11.6 3.2 8.6 a4.4 4.4 0 0 1 8.8 -1 a4.4 4.4 0 0 1 8.8 1 c0 3 -1.8 5.9 -8.8 11.4 z"/>',
    "music": f'<path {S} d="M9 17.5 V5.5 L19 3.5 V15.5"/><circle {S} cx="6.8" cy="17.8" r="2.3"/><circle {S} cx="16.8" cy="15.8" r="2.3"/>',
    "play": f'<path {F} d="M8 5.5 L19 12 L8 18.5 Z"/>',
    "stop": f'<rect {F} x="6.5" y="6.5" width="11" height="11" rx="2"/>',
    "call": f'<path {S} d="M6.6 3.8 L9.6 3 L11.4 7.4 L9.5 8.8 C10.5 10.9 12.3 12.7 14.5 13.8 L16 12 L20.4 13.8 L19.6 16.9 C19.3 18.2 18 19 16.7 18.8 C10 17.7 6.3 14 5.1 7.4 C4.9 6 5.5 4.5 6.6 3.8 Z"/>',
    "text": f'<path {S} d="M5 5 H19 a1.5 1.5 0 0 1 1.5 1.5 V14.5 a1.5 1.5 0 0 1 -1.5 1.5 H12 L7.5 19.5 V16 H5 a1.5 1.5 0 0 1 -1.5 -1.5 V6.5 A1.5 1.5 0 0 1 5 5 Z"/>',
    "web": f'<circle {S} cx="12" cy="12" r="8.5"/><ellipse {S} cx="12" cy="12" rx="3.8" ry="8.5"/><path {S} d="M3.8 9.5 H20.2 M3.8 14.5 H20.2"/>',
    "lock": f'<rect {S} x="5.5" y="10.5" width="13" height="9.5" rx="2.4"/><path {S} d="M8.5 10.5 V8 a3.5 3.5 0 0 1 7 0 V10.5"/>',
    "unlock": f'<rect {S} x="5.5" y="10.5" width="13" height="9.5" rx="2.4"/><path {S} d="M8.5 10.5 V8 a3.5 3.5 0 0 1 6.8 -1.2"/>',
    "delete": f'<path {S} d="M5 7 H19 M9.5 7 V5 H14.5 V7 M6.5 7 L7.4 19.5 H16.6 L17.5 7 M10 11 V16 M14 11 V16"/>',
    "edit": f'<path {S} d="M5 19 L5.8 15 L16 4.8 a1.8 1.8 0 0 1 2.5 0 L19.2 5.5 a1.8 1.8 0 0 1 0 2.5 L9 18.2 Z M14.5 6.5 L17.5 9.5"/>',
    "person": f'<circle {S} cx="12" cy="8.5" r="3.6"/><path {S} d="M4.8 20 C5.5 15.5 8.3 14 12 14 C15.7 14 18.5 15.5 19.2 20"/>',
    "swap": f'<path {S} d="M5 9 H19 L15.5 5.5 M19 15 H5 L8.5 18.5"/>',
    "info": f'<circle {S} cx="12" cy="12" r="8.5"/><path {S} d="M12 11 V16.5"/><circle {F} cx="12" cy="7.8" r="0.9"/>',
    "document": f'<path {S} d="M7 3.5 H14 L18.5 8 V20.5 H7 Z M14 3.5 V8 H18.5 M9.5 12.5 H16 M9.5 16 H16"/>',
    "tour": f'<path {S} d="M4 5.5 C7 4.5 9.5 4.8 12 6.5 C14.5 4.8 17 4.5 20 5.5 V18.5 C17 17.5 14.5 17.8 12 19.5 C9.5 17.8 7 17.5 4 18.5 Z M12 6.5 V19.5"/>',
    "alert": f'<path {S} d="M12 4 L21 19.5 H3 Z"/><path {S} d="M12 10 V14.5"/><circle {F} cx="12" cy="17" r="0.8"/>',
    "chart": f'<path {S} d="M5 20 V12 M10 20 V5 M15 20 V9 M20 20 V14"/>',
    "volume": f'<path {S} d="M4 9.5 H8 L13 5.5 V18.5 L8 14.5 H4 Z"/><path {S} d="M16.5 9 a4 4 0 0 1 0 6 M18.7 6.8 a7 7 0 0 1 0 10.4"/>',
}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for stale in OUT.glob("*.svg"):
        stale.unlink()
    for name, body in ICONS.items():
        (OUT / f"{name}.svg").write_text(
            f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">{body}</svg>\n', encoding="utf-8")
    print(f"{len(ICONS)} icons written to {OUT}")


if __name__ == "__main__":
    main()
