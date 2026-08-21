#!/usr/bin/env bash
#
# Bootstrap: symlink these dotfiles into $HOME.
# Idempotent: safe to re-run; existing non-symlink targets are skipped with a warning.
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
	local src="$DOTFILES/$1" dst="$HOME/${2:-$1}"
	if [ -e "$dst" ] && [ ! -L "$dst" ]; then
		echo "  ! $dst exists and is not a symlink, skipping"
		return
	fi
	mkdir -p "$(dirname "$dst")"
	ln -sfn "$src" "$dst"
	echo "  $dst -> $src"
}

echo "==> Home files"
for f in .zshrc .bashrc .tmux.conf .vimrc .golangci.yaml amoled.json; do
	link "$f"
done

echo "==> ~/.config"
for d in "$DOTFILES"/.config/*/; do
	link ".config/$(basename "$d")"
done
link ".config/mimeapps.list"

echo "==> Scripts"
for f in "$DOTFILES"/.local/bin/*; do
	link ".local/bin/$(basename "$f")"
done

echo "==> Wallpapers"
link "wallpapers"

echo "==> Claude Code & agents"
mkdir -p "$HOME/.claude"
for item in settings.json commands hooks skills; do
	link ".claude/$item"
done
link ".agents"
link ".pi"

echo
echo "==> Done. Next steps:"
echo "    claude/install.sh        # Claude Code plugins & MCP servers"
echo "    dms greeter install -t   # DMS login screen (greetd)"
