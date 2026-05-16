#!/usr/bin/env python3

from __future__ import annotations

import os
import subprocess
from pathlib import Path


OVERRIDE = Path(__file__).resolve().parent / "theme-override"

PALETTES = {
    "dark": {
        "foreground": "#dadada",
        "background": "#000000",
        "cursor": "#ffaf00",
        "cursor_text": "#000000",
        "selection_foreground": "#000000",
        "selection_background": "#ffaf00",
        "ansi": [
            "#000000",
            "#b35a4f",
            "#6d8758",
            "#ffaf00",
            "#6c8db5",
            "#9a7bb8",
            "#5d9690",
            "#dadada",
        ],
        "brights": [
            "#4a4a4a",
            "#d77a61",
            "#93ad6d",
            "#ffaf00",
            "#8eabd1",
            "#b59ad1",
            "#7db8af",
            "#f3eadb",
        ],
    },
    "light": {
        "foreground": "#000000",
        "background": "#fff7df",
        "cursor": "#ffaf00",
        "cursor_text": "#000000",
        "selection_foreground": "#000000",
        "selection_background": "#ffaf00",
        "ansi": [
            "#000000",
            "#ad5a4d",
            "#5f7a4f",
            "#ffaf00",
            "#5e7fa8",
            "#866ea8",
            "#4f8b85",
            "#6f6557",
        ],
        "brights": [
            "#9b907f",
            "#cf745d",
            "#78935f",
            "#ffaf00",
            "#7d98bd",
            "#a189c0",
            "#6ea79f",
            "#fff7df",
        ],
    },
}


def is_light_mode() -> bool:
    override = os.environ.get("KITTY_THEME") or (
        OVERRIDE.read_text(encoding="utf-8").strip() if OVERRIDE.exists() else ""
    )
    if override in {"light", "dark"}:
        return override == "light"

    gtk_theme = os.environ.get("GTK_THEME", "").lower()
    if gtk_theme:
        return "dark" not in gtk_theme

    try:
        result = subprocess.run(
            ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"],
            capture_output=True,
            check=False,
            text=True,
        )
    except FileNotFoundError:
        result = None

    if result and result.returncode == 0:
        value = result.stdout.strip().strip("'").lower()
        if value:
            return value != "prefer-dark"

    return True


mode = "light" if is_light_mode() else "dark"
palette = PALETTES[mode]

print(f"foreground {palette['foreground']}")
print(f"background {palette['background']}")
print()
print(f"cursor {palette['cursor']}")
print(f"cursor_text_color {palette['cursor_text']}")
print(f"selection_foreground {palette['selection_foreground']}")
print(f"selection_background {palette['selection_background']}")
print()

for index, color in enumerate(palette["ansi"]):
    print(f"color{index} {color}")
for index, color in enumerate(palette["brights"], start=8):
    print(f"color{index} {color}")
