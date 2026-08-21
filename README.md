# dotfiles

CachyOS + [niri](https://github.com/YaLTeR/niri) + [DankMaterialShell](https://danklinux.com).
Monochrome AMOLED theme with an orange accent, light and dark modes everywhere —
from the login screen to the wallpapers.

![desktop](docs/desktop.png)

## Wallpapers

Two sets that follow the theme mode automatically. Dark: black with highlights
tinted to the theme foreground (`#fffaf0`). Light: ink-on-ivory duotone
(`#fff7df`, the light theme background). Untouched sources live in
`wallpapers/originals/`.

| Dark | Light |
|---|---|
| ![dark](docs/wallpapers-dark.png) | ![light](docs/wallpapers-light.png) |

Picker: the [Wallpaper Carousel](https://github.com/motor-dev/wallpaperCarousel)
DMS plugin — fullscreen 3D carousel on `Mod+T` / `Mod+W`.

## Install

```sh
git clone git@github.com:Nap20192/dotfiles.git ~/dotfiles
~/dotfiles/install.sh          # symlink all configs into $HOME
~/dotfiles/claude/install.sh   # Claude Code plugins & MCP servers
dms greeter install -t         # DMS login screen (greetd), optional
```

`install.sh` is idempotent: existing non-symlink targets are skipped with a warning.

## Required packages

Core:

```
niri dms quickshell ghostty tmux neovim yazi thunar zsh git
pipewire wireplumber xdg-desktop-portal-gnome xdg-desktop-portal-gtk
```

Login screen: `greetd` + `greetd-dms-greeter-git` (AUR) — or just run
`dms greeter install -t`.

Shell extras: `zinit` (auto-installed by `.zshrc`), `powerlevel10k`.

Fonts: `GoMono Nerd Font` (terminal), Material Symbols (pulled in by DMS).

Optional: `herdr` (agent terminal workspace), `claude-code`,
`imagemagick` + `ffmpeg` (only to regenerate wallpaper recolors and
quiet notification sounds).

## Keybindings

| Keys | Action |
|---|---|
| `Mod+Return` | terminal |
| `Mod+Shift+T` | floating terminal |
| `Mod+D` | launcher |
| `Mod+T` / `Mod+W` | wallpaper carousel |
| `Mod+Ctrl+W` / `+Shift` | next / previous wallpaper |
| `Ctrl+h/j/k/l` in herdr | vim-aware pane navigation |

Full list: `.config/niri/binds.kdl`.

## Notes

- **Quiet notifications**: DMS sound volume is pinned to 10% via WirePlumber
  stream-restore; herdr plays its own 10%-volume mp3s (`.config/herdr/sounds/`).
- **herdr vim-nav**: local plugin (`.config/herdr/plugins-local/vim-nav/`) —
  `ctrl+hjkl` passes through to nvim when focused, otherwise moves pane focus.
- **Claude Code**: `.claude/` (settings, commands, hooks, skills) and `.agents/`
  are tracked here; home paths are symlinks.
