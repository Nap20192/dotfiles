#!/usr/bin/env bash
# vim-tmux-navigator for herdr: if the focused pane runs (n)vim, pass the
# ctrl+hjkl key through; otherwise move herdr pane focus.
set -euo pipefail

dir=$1
case "$dir" in
left) key=ctrl+h ;;
down) key=ctrl+j ;;
up) key=ctrl+k ;;
right) key=ctrl+l ;;
*) exit 1 ;;
esac

herdr=${HERDR_BIN_PATH:-herdr}
pane=$(printf '%s' "${HERDR_PLUGIN_CONTEXT_JSON:-}" | grep -o '"focused_pane_id":"[^"]*"' | cut -d'"' -f4)
[ -z "$pane" ] && exit 0

# ponytail: grep-parse instead of jq; process-info name match covers vim/nvim/vimdiff
if "$herdr" pane process-info --pane "$pane" | grep -qE '"name":"n?vim[^"]*"'; then
	"$herdr" pane send-keys "$pane" "$key"
else
	"$herdr" pane focus --pane "$pane" --direction "$dir"
fi
