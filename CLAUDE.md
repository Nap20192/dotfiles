# dotfiles

Personal dotfiles managed with GNU Stow.

## Structure

Each top-level directory is a **stow package** (one per tool):

```
dotfiles/
├── nvim/         → stow package
├── wezterm/      → stow package
├── tmux/         → stow package
├── niri/         → stow package
└── zsh/          → stow package
```

Stow's default target is the **parent of the stow directory** (`~`). It creates symlinks in `~` that mirror the tree inside each package. So the path inside the package must match the desired path relative to `~`:

- `nvim/.config/nvim/`  → `~/.config/nvim/`  (symlink to dir)
- `wezterm/.config/wezterm/` → `~/.config/wezterm/`
- `niri/.config/niri/` → `~/.config/niri/`
- `tmux/.tmux.conf`    → `~/.tmux.conf`
- `zsh/.zshrc`         → `~/.zshrc`

### Why the nested `.config/` dirs?

This is required by stow's folding algorithm. The package tree is a mirror of `~`, so files that live in `~/.config/X` must be stored as `package/.config/X`. There is no other way to do this with stow.

### Can the structure be changed?

The nesting is mandatory for stow to work correctly. The only alternative is to pass an explicit `--target` per package, but that defeats the purpose. The structure is intentional and correct — it is not strange, it is how stow works.

## Commands

```bash
# From ~/dotfiles
stow .             # stow all packages at once
stow -D nvim       # remove symlinks for nvim
stow -R nvim       # re-stow (remove + re-create)
```

## How to make changes

- **Edit files in `~/dotfiles/<package>/...`** — never edit the symlink targets directly.
- After adding a new file: run `stow .` from `~/dotfiles` to create symlinks.
- To add a new tool: create `dotfiles/<toolname>/` with the correct mirrored path inside.
- Files that belong in `~/.config/X/` go under `<package>/.config/X/`.
- Files that belong in `~/` (dotfiles like `.zshrc`) go directly in `<package>/`.

## Unix philosophy

- One package per tool — each directory is independently stowable.
- No scripts, no framework, no magic: just symlinks.
- The repo is the source of truth; the home directory contains only symlinks.
