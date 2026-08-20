---
description: Force-spawn a real researcher/tester/updater agent team for a task
argument-hint: [task description]
---

Target: $ARGUMENTS

Spawn a real agent team for this (agent teams are enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`). Use the Agent tool with a `name` parameter for each teammate — do not use the Workflow tool and do not use unnamed/plain subagents, this must be a real team that can message each other.

Spawn exactly three teammates immediately, no confirmation needed:

- **researcher** — investigates the target, reports concrete problems with file:line evidence and a proposed fix per finding. Does not fix anything.
- **tester** — takes each of researcher's findings and verifies it with real commands (run the check, read the file, don't assume). Marks each real vs false positive, and whether the fix is safe to automate.
- **updater** — applies only tester-confirmed, safe, mechanical fixes. Leaves anything needing judgment for a human. Reports exactly what changed.

Have researcher message tester once findings exist, and tester message updater once verified. Wait for all three to finish, then synthesize their reports for the user. If $ARGUMENTS is empty, ask what to investigate before spawning anyone.
