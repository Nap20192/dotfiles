#!/usr/bin/env python3

from __future__ import annotations

import os
import subprocess
from pathlib import Path

OVERRIDE = Path(__file__).resolve().parent / "theme-override"

PALETTES = {
    "dark": {
        "foreground": "#fff7df",
        "background": "#000000",
        "cursor": "#ffaf00",
        "cursor_text": "#000000",
        "selection_foreground": "#000000",
        "selection_background": "#ffaf00",
        "surface0": "#1f1b12",
        "surface1": "#332a19",
        "surface2": "#6f6557",
        "border_active": "#ffaf00",
        "border_inactive": "#6f6557",
        "bell": "#cf745d",
        "tab_active_foreground": "#000000",
        "tab_active_background": "#ffaf00",
        "tab_inactive_foreground": "#fff7df",
        "tab_inactive_background": "#1f1b12",
        "tab_bar_background": "#000000",
        "mark1": "#5e7fa8",
        "mark2": "#866ea8",
        "mark3": "#4f8b85",
        "ansi": [
            "#000000",
            "#ad5a4d",
            "#5f7a4f",
            "#ffaf00",
            "#5e7fa8",
            "#866ea8",
            "#4f8b85",
            "#fff7df",
        ],
        "brights": [
            "#6f6557",
            "#cf745d",
            "#78935f",
            "#ffaf00",
            "#7d98bd",
            "#a189c0",
            "#6ea79f",
            "#fff7df",
        ],
    },
    "light": {
        "foreground": "#000000",
        "background": "#fff7df",
        # "background": "#ffffff",
        "cursor": "#ffaf00",
        "cursor_text": "#000000",
        "selection_foreground": "#000000",
        "selection_background": "#ffaf00",
        "surface0": "#f3eadb",
        "surface1": "#ddd2bf",
        "surface2": "#9b907f",
        "border_active": "#ffaf00",
        "border_inactive": "#9b907f",
        "bell": "#cf745d",
        "tab_active_foreground": "#000000",
        "tab_active_background": "#ffaf00",
        "tab_inactive_foreground": "#000000",
        "tab_inactive_background": "#f3eadb",
        "tab_bar_background": "#fff7df",
        "mark1": "#5e7fa8",
        "mark2": "#866ea8",
        "mark3": "#4f8b85",
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

# Layout follows catppuccin/kitty themes/*.conf, with this repo's palette.
print("# vim:ft=kitty")
print(f"## name: vnkjd {mode}")
print("## author: vnkjd")
print("## upstream: https://github.com/catppuccin/kitty")
print("## blurb: Catppuccin kitty layout with vnkjd colors")
print()
print("# The basic colors")
print(f"foreground {palette['foreground']}")
print(f"background {palette['background']}")
print(f"selection_foreground {palette['selection_foreground']}")
print(f"selection_background {palette['selection_background']}")
print()
print("# Cursor colors")
print(f"cursor {palette['cursor']}")
print(f"cursor_text_color {palette['cursor_text']}")
print()
print("# Scrollbar colors")
print(f"scrollbar_handle_color {palette['surface2']}")
print(f"scrollbar_track_color {palette['surface0']}")
print()
print("# URL color when hovering with mouse")
print(f"url_color {palette['cursor']}")
print()
print("# Kitty window border colors")
print(f"active_border_color {palette['border_active']}")
print(f"inactive_border_color {palette['border_inactive']}")
print(f"bell_border_color {palette['bell']}")
print()
print("# OS Window titlebar colors")
print("wayland_titlebar_color system")
print("macos_titlebar_color system")
print()
print("# Tab bar colors")
print(f"active_tab_foreground {palette['tab_active_foreground']}")
print(f"active_tab_background {palette['tab_active_background']}")
print(f"inactive_tab_foreground {palette['tab_inactive_foreground']}")
print(f"inactive_tab_background {palette['tab_inactive_background']}")
print(f"tab_bar_background {palette['tab_bar_background']}")
print()
print("# Colors for marks (marked text in the terminal)")
print(f"mark1_foreground {palette['background']}")
print(f"mark1_background {palette['mark1']}")
print(f"mark2_foreground {palette['background']}")
print(f"mark2_background {palette['mark2']}")
print(f"mark3_foreground {palette['background']}")
print(f"mark3_background {palette['mark3']}")
print()

print("# The 16 terminal colors")
print("# black")
for index, color in enumerate(palette["ansi"]):
    if index == 1:
        print()
        print("# red")
    elif index == 2:
        print()
        print("# green")
    elif index == 3:
        print()
        print("# yellow")
    elif index == 4:
        print()
        print("# blue")
    elif index == 5:
        print()
        print("# magenta")
    elif index == 6:
        print()
        print("# cyan")
    elif index == 7:
        print()
        print("# white")
    print(f"color{index} {color}")
    print(f"color{index + 8} {palette['brights'][index]}")
