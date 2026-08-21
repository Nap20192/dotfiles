---
description: Spawn a claude agent team as herdr panes; roles come from the user or from your own reasoning
argument-hint: [task, optionally with explicit roles]
---

Target: $ARGUMENTS

Spawn an agent team rendered in herdr panes. If $ARGUMENTS is empty, ask what
to work on before spawning anyone.

**Team composition — never use a fixed template.** Decide roles like this:
- If $ARGUMENTS names roles/agents explicitly (e.g. "два ревьюера и один
  фиксер", "ux + architecture + devil's advocate") — use exactly those.
- Otherwise reason from the task itself: what independent perspectives or
  workstreams does THIS task actually need? Pick 2-5 roles with distinct,
  non-overlapping responsibilities and give each a short lowercase name and a
  precise role prompt (scope, deliverable, what NOT to do). State your chosen
  composition and why in one sentence before spawning.

First check `test "${HERDR_ENV:-}" = 1`. If NOT inside herdr, fall back to a
native agent team: use the Agent tool with a `name` per teammate (agent teams
are enabled via CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS) and skip the rest.

Inside herdr, build the team with the herdr CLI (load the herdr skill first):

1. Create a new tab in the current workspace (`herdr tab create`), then split
   one pane per teammate, all with cwd = current repo root. Parse every pane
   ID from the JSON responses; use `--no-focus` everywhere.
2. `herdr agent start <name> --kind claude --pane <id>` per teammate.
3. `herdr agent prompt <name> "<role prompt + task context>" --wait` — each
   prompt must be self-contained: teammates don't see this conversation.

Herdr agents cannot message each other — you are the relay. Sequence or
parallelize according to the dependencies between roles you defined: read a
settled teammate's output (`herdr agent read <name> --source recent-unwrapped
--lines 200`; if truncated, ask it to write a temp file and read that) and
feed it to whoever needs it. If a prompt returns `agent_blocked`, inspect
with `agent read` and ask the user before answering the dialog.

When everyone settles, synthesize the reports for the user. Leave the panes
open so the user can talk to any teammate directly; tell them which tab.
