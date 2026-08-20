# Theme design — vnkjd

Monochrome base (black/cream) + single amber accent (`#ffaf00`), light and dark
variants. Governs: ghostty, kitty, DMS (Dank Material Shell) bar, niri
focus-ring/highlights, nvim colorscheme (`vnkjd-monochrome`, currently identical
in both modes — see `nvim/lua/vnkjd/functions/theme.lua`).

## Light

| Role | Hex | Used in |
|---|---|---|
| Background | `#fff7df` | ghostty (`themes/vnkjd-light`), DMS (`amoled.json` → `white.light.background/surface`) |
| Background (kitty, **drifted**) | `#fffaf0` | kitty (`theme-light.conf`) — see Known drift below |
| Foreground / text | `#000000` (ghostty) / `#18130d` (kitty) | terminal text |
| Accent (cursor, selection, links) | `#ffaf00` | ghostty, kitty — identical in both |
| Accent (DMS `primaryContainer`) | `#cc5200` | DMS bar chips/buttons — **different accent**, see below |

ANSI palette (ghostty `themes/vnkjd-light`): red `#ad5a4d`, green `#5f7a4f`,
yellow/accent `#ffaf00`, blue `#5e7fa8`, magenta `#866ea8`, cyan `#4f8b85`.

## Dark

| Role | Hex | Used in |
|---|---|---|
| Background | `#000000` | ghostty (`themes/vnkjd-dark`), DMS (`amoled.json` → `black.dark.background/surface`) — exact match |
| Background (kitty, **drifted**) | `#080706` | kitty (`theme-dark.conf`) — near-black, not pure black |
| Foreground / text | `#dadada` (ghostty) / `#f4efe6` (kitty) | terminal text |
| Accent (cursor, selection, links) | `#ffaf00` | ghostty, kitty — identical in both |
| Accent (DMS `primaryContainer`) | `#cc5200` | same drift as light mode |

## Source of truth per app

| App | File | Switches via |
|---|---|---|
| ghostty | `.config/ghostty/themes/vnkjd-{light,dark}` | `theme = light:vnkjd-light,dark:vnkjd-dark` in `config`, follows GTK/portal `color-scheme` |
| kitty | `.config/kitty/theme-{light,dark}.conf` | `*.auto.conf` includes, same portal signal |
| DMS bar | `amoled.json` (repo root) | `dms ipc call theme light\|dark`, `customThemeFile` in `~/.config/DankMaterialShell/settings.json` |
| niri | `.config/niri/colors.kdl` | static, not theme-linked (`#fff7df` focus-ring, `#cc5200` recent-windows highlight — matches DMS accent, not ghostty/kitty accent) |
| nvim | `vnkjd-monochrome` colorscheme | forced identical in light/dark, not portal-linked |

The portal chain (GTK `color-scheme` gsetting → freedesktop `org.freedesktop.appearance`
portal) only moves if DMS's `runDmsMatugenTemplates` setting is `true` — that was
the root cause of an earlier "theme switch doesn't propagate" bug, now fixed.

## Known drift (not yet reconciled)

1. **kitty vs ghostty background**: `#fffaf0` vs `#fff7df` (light), `#080706` vs
   `#000000` (dark). Drift exists across most of the 16-color ANSI palette too,
   not just background — looks hand-tuned independently rather than copied.
   Fixing this means rewriting one file wholesale to match the other; ask before
   doing it, it's a visible daily-use asset.
2. **DMS accent vs terminal accent**: DMS's Material `primaryContainer` is
   `#cc5200` (burnt orange), terminals use `#ffaf00` (amber) for cursor/selection.
   niri's `recent-windows` highlight also uses `#cc5200`, its focus-ring uses
   `#fff7df` — so the two accents already coexist deliberately in different UI
   layers (bar chips vs terminal cursor vs window highlight). Not obviously a bug;
   flagged here in case it should become one color.

## Fixed this pass

DMS `amoled.json` light background/surface was `#fffaf0`, ghostty was `#fff7df`
— visibly different cream shades between the bar and the terminal below it.
Changed DMS to `#fff7df` to match ghostty (dark mode already matched exactly at
`#000000`). Live-applied via `dms ipc call theme dark && dms ipc call theme light`
to force matugen to regenerate.
