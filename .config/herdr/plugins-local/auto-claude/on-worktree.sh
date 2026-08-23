#!/usr/bin/env bash
# herdr event hook (worktree.created / worktree.opened): start a claude agent
# in the new worktree workspace's root pane.
set -euo pipefail

herdr=${HERDR_BIN_PATH:-herdr}
evt=${HERDR_PLUGIN_EVENT_JSON:-}
[ -z "$evt" ] && exit 0

read -r ws branch < <(printf '%s' "$evt" | python3 -c '
import json, sys
d = json.load(sys.stdin)
wt = d.get("worktree") or d.get("data", {}).get("worktree") or {}
print(wt.get("open_workspace_id") or "", (wt.get("branch") or "wt"))
')
[ -z "$ws" ] && exit 0

# agent name from branch: [a-z][a-z0-9_-]{0,31}, unique-ish
name=$(printf '%s' "$branch" | tr 'A-Z/.' 'a-z--' | tr -cd 'a-z0-9_-' | cut -c1-24)
case "$name" in [a-z]*) ;; *) name="wt-$name" ;; esac

pane=$("$herdr" pane list --workspace "$ws" | python3 -c '
import json, sys
panes = json.load(sys.stdin)["result"]["panes"]
free = [p for p in panes if not p.get("agent")]
print(free[0]["pane_id"] if free else "")
')
[ -z "$pane" ] && exit 0

# shell may still be booting right after worktree creation; retry briefly
for _ in 1 2 3 4 5; do
	if "$herdr" agent start "$name" --kind claude --pane "$pane" >/dev/null 2>&1; then
		exit 0
	fi
	sleep 2
done
exit 0
