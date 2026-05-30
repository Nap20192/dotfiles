# Theme Variants

The `new-orange` branch uses `#ff9900` with neutral surfaces and muted
secondary colors.

The vivid accent is reserved for cursors, selections, active tabs, and borders.
On light surfaces, readable orange text uses `#a35b00` instead.

## Kitty

Kitty switches automatically between:

```conf
dark-theme.auto.conf
light-theme.auto.conf
no-preference-theme.auto.conf
```

## Ghostty

`.config/ghostty/config` includes `.config/ghostty/theme.conf`. To switch its
static variant manually:

```sh
cp ~/.config/ghostty/theme-orange-dark.conf ~/.config/ghostty/theme.conf
cp ~/.config/ghostty/theme-orange-light.conf ~/.config/ghostty/theme.conf
```

## WezTerm

The active WezTerm light and dark palettes use the orange variant.

## Neovim

The active colorscheme is:

```vim
:colorscheme vnkjd-orange
```

## Tmux

The active tmux config uses the orange variant. Reload it with:

```sh
tmux source-file ~/.tmux.conf
```

## Niri

`.config/niri/config.kdl` sources `layout-orange.kdl`.

## Yazi

`.config/yazi/theme.toml` uses:

```toml
[flavor]
dark  = "orange-dark"
light = "orange-light"
```
