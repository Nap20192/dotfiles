# Agent Config Efficiency Review: token/tool-call/cost

Root: `/home/vnkjd/.pi`  
Primary config: `agent/settings.json`  
Scope: static inspection only. No edits.

## Executive recommendation

Keep the safety/control pieces that cost little (`bash-guard`, `read-only`, `/context`, Ponytail). Cut duplicate web/video tooling and stop defaulting routine work to premium model + subagents.

Highest ROI changes:

1. Change default model from `gpt-5.5` to a cheaper daily model and use high-end models only when needed.
2. Remove local `web-fetch` and `video-extract`; `pi-web-access` already covers fetch/PDF/video.
3. Remove or disable rare media search tools unless used often: `google_image_search`, `youtube_search`.
4. Rewrite/remove the local `orchestrator` skill’s “default to scouts” policy; subagents should be for broad/parallel work, not routine exploration.
5. Relax `bash-guard` so read-only git commands do not prompt.

## Findings

### High: premium model is the default for every task

Evidence:
- `agent/settings.json:5` sets `"defaultModel": "gpt-5.5"`.
- `agent/settings.json:6` sets `"defaultThinkingLevel": "medium"`.
- `agent/models-store.json:439-451` shows `gpt-5.5` costs input `5`, output `30`.
- Cheaper available models exist: `gpt-5.4-mini` at input `0.75`, output `4.5` (`agent/models-store.json:411-423`) and `gpt-5.6-luna` at input `0.2`, output `1.2` (`agent/models-store.json:476-488`).

Cost impact:
- `gpt-5.5` is about 6.7x the token price of `gpt-5.4-mini`.
- It is about 25x the token price of `gpt-5.6-luna`.

Minimal change:
- Set daily default to `gpt-5.4-mini` or `gpt-5.6-luna`.
- Set default thinking to minimal/low if supported.
- Manually switch to `gpt-5.5` for hard architecture, high-risk edits, or final review.

Severity: high.

---

### High: duplicate web/PDF/video tools inflate tool schema and confuse tool choice

Evidence:
- `agent/settings.json:8` installs `npm:pi-web-access`.
- `pi-web-access` enables all four tools by default when no config disables them: `agent/npm/node_modules/pi-web-access/index.ts:247-250`, `943-946`.
- `pi-web-access` registers:
  - `web_search` at `agent/npm/node_modules/pi-web-access/index.ts:1660-1667`
  - `source_check` at `2232-2237`
  - `fetch_content` at `2326-2332`
  - `get_search_content` at `2667-2673`
- `fetch_content` already handles readable/raw URL content, images, GitHub repos, videos, PDFs, and local videos: `agent/npm/node_modules/pi-web-access/index.ts:2329-2331`, with video frame/timestamp support at `2348-2356`.
- Local `web_fetch` duplicates web/PDF extraction: `agent/extensions/web-fetch/index.ts:548-557`.
- Local `video_extract` duplicates YouTube/local video extraction and Gemini analysis: `agent/extensions/video-extract/index.ts:1145-1155`.
- Local `web-fetch` carries the same dependency family as `pi-web-access`: `agent/extensions/web-fetch/package.json:9-12` and `agent/npm/node_modules/pi-web-access/package.json:46-54`.

Cost impact:
- More tool schemas in every model tool list.
- More chance the model calls the wrong web/video tool, then calls another.
- Duplicated dependency trees under `agent/extensions/web-fetch/node_modules/`.

Minimal change:
- Keep `pi-web-access`.
- Remove local `agent/extensions/web-fetch/`.
- Remove local `agent/extensions/video-extract/`.

Severity: high.

---

### Medium: image tools can inject expensive image tokens by default

Evidence:
- `google_image_search` fetches thumbnails and returns image blocks: `agent/extensions/google-image-search/index.ts:79-87`.
- Default result count is 5, max 10: `agent/extensions/google-image-search/index.ts:49-60`.
- `video_extract` returns frames/thumbnails as image blocks: `agent/extensions/video-extract/index.ts:1220-1234`.

Cost impact:
- Image blocks are much more expensive than text.
- Search-style image tools invite multiple thumbnails even when URLs/text metadata would be enough.

Minimal change:
- Remove `google_image_search` unless visual image selection is frequent.
- If kept, add a parameter like `include_thumbnails` defaulting to `false`.
- Prefer text URLs first; fetch images only after the user picks candidates.

Severity: medium.

---

### Medium: subagent/orchestrator policy over-delegates routine exploration

Evidence:
- Local orchestrator skill says “Default to scouts for exploration” and “Never explore a codebase by reading files yourself”: `agent/skills/orchestrator/SKILL.md:25-34`.
- `pi-subagents` skill says to use `workflowScript` even for one isolated child and async by default: `agent/npm/node_modules/pi-subagents/skills/pi-subagents/SKILL.md:15`.
- It also instructs reading reference files before acting: `agent/npm/node_modules/pi-subagents/skills/pi-subagents/SKILL.md:19-28`.
- Package registers `subagent` and wait/slash infrastructure: `agent/npm/node_modules/pi-subagents/src/extension/index.ts:597-642`, `665`.

Cost impact:
- Subagents are separate model runs with their own prompts, tool calls, and summaries.
- Good for broad/parallel work; wasteful for “inspect 2 files and patch 1 line.”

Minimal change:
- Keep `pi-subagents` only if you actually use review/scout/worker fanout.
- Change local orchestrator rule to: direct read/grep first for small scoped tasks; subagents only for broad, uncertain, or parallel work.
- If multi-agent work is rare, remove `npm:pi-subagents`.

Severity: medium.

---

### Medium: `bash-guard` prompts on any git command

Evidence:
- `bash-guard` explicitly prompts for any `git` command: `agent/extensions/bash-guard/index.ts:87-93`.
- Hook applies to bash tool calls: `agent/extensions/bash-guard/index.ts:427-456`.

Cost impact:
- Common cheap checks like `git status`, `git diff`, `git log`, `git show` become interactive interruptions.
- Interruptions can cause retries or parent handoffs.

Minimal change:
- Keep `bash-guard`.
- Allow read-only git commands without prompt: `status`, `diff`, `log`, `show`, `branch --show-current`, `rev-parse`.
- Keep prompts/blocks for mutating git commands.

Severity: medium.

---

### Medium: FFF adds duplicate search tools unless it replaces built-ins

Evidence:
- Default FFF mode is `"tools-and-ui"`: `agent/npm/node_modules/@ff-labs/pi-fff/src/index.ts:308`.
- In that mode it registers `ffgrep` and `fffind`, not built-in `grep`/`find`: `agent/npm/node_modules/@ff-labs/pi-fff/src/index.ts:58-70`, `706-711`, `891-896`.
- Built-in/default limits are already bounded: grep 20, find 30 at `agent/npm/node_modules/@ff-labs/pi-fff/src/index.ts:35-36`.
- It indexes on session start: `agent/npm/node_modules/@ff-labs/pi-fff/src/index.ts:583-612`.
- Home scanning defaults on when launched from `$HOME`: `agent/npm/node_modules/@ff-labs/pi-fff/src/index.ts:343-346`, `616-620`.

Cost impact:
- Extra `ffgrep`/`fffind` schemas increase tool list size.
- But FFF can reduce exploration calls in large repos.

Minimal change:
- Keep FFF for large repos.
- If you keep it, prefer one search surface, not two: use FFF as replacement only after resolving conflict with `zz-read-only-mode.ts`, which re-registers built-in `grep`/`find` at `agent/extensions/zz-read-only-mode.ts:69-81`.
- If repos are small, remove `npm:@ff-labs/pi-fff`.

Severity: medium.

---

### Low/Medium: `filechanges` stores full original file contents for undo

Evidence:
- Tracks edit/write tool calls: `agent/extensions/filechanges/index.ts:538-547`.
- Stores baseline entries with `originalContent`: `agent/extensions/filechanges/index.ts:17-24`, `564-569`.
- Rebuilds state from session entries: `agent/extensions/filechanges/index.ts:489-496`.

Cost impact:
- Strong safety/control.
- Possible session/storage bloat for large files. Direct model-token impact depends on how host includes custom entries.

Minimal change:
- Keep if you use “decline/revert” often.
- Otherwise remove and rely on git diff/checkout.
- If kept, add a max baseline size or skip generated/binary/large files.

Severity: low/medium.

---

### Low: memory extension is disabled by default but expensive when enabled

Evidence:
- `memoryEnabled` starts false: `agent/extensions/memory.ts:52`.
- Only injects prompt when enabled: `agent/extensions/memory.ts:110-114`.
- Injected prompt tells the agent to read and update `MEMORY.md`: `agent/extensions/memory.ts:38-48`.

Cost impact:
- No cost while off.
- When on, it adds system prompt tokens and causes extra read/write behavior.

Minimal change:
- Keep disabled.
- Remove if not used.
- If kept, change “update whenever you learn something” to “update only when explicitly asked or at wrap-up.”

Severity: low unless enabled.

---

### Low: `/context` is useful and cheap

Evidence:
- Command only: `agent/extensions/context.ts:496-497`.
- Computes token/cost stats from session usage: `agent/extensions/context.ts:81-102`, `133`, `428`.

Cost impact:
- No per-turn tool schema cost beyond command registration.
- Helps reduce waste.

Minimal change:
- Keep.

Severity: keep.

---

### Low: Ponytail likely reduces code/token waste

Evidence:
- Package injects instructions before agent start: `agent/npm/node_modules/@dietrichgebert/ponytail/pi-extension/index.js:204-209`.
- It registers mode/help/audit commands: `agent/npm/node_modules/@dietrichgebert/ponytail/pi-extension/index.js:114-170`.

Cost impact:
- Adds system prompt tokens.
- Usually offsets that by reducing overbuild and output length.

Minimal change:
- Keep `full`.
- Do not use `ultra` on security/data-loss/accessibility work.

Severity: keep.

---

### Low: read-only mode is worth its small prompt cost when enabled

Evidence:
- Allows only read/grep/find/ls: `agent/extensions/zz-read-only-mode.ts:22-26`.
- Adds a short system prompt only when enabled: `agent/extensions/zz-read-only-mode.ts:170-184`.
- Blocks other tool calls while enabled: `agent/extensions/zz-read-only-mode.ts:190`.

Cost impact:
- Small prompt overhead only in read-only mode.
- Prevents costly accidental write/revert cycles.

Minimal change:
- Keep.
- Revisit only if using FFF override because this extension re-registers built-in grep/find.

Severity: keep.

## Keep/remove/change list

### Keep
- `npm:@dietrichgebert/ponytail`
- `agent/extensions/bash-guard/`, with read-only git allowlist change
- `agent/extensions/zz-read-only-mode.ts`
- `agent/extensions/context.ts`
- `agent/extensions/ask-user-question.ts`, but use sparingly
- `agent/extensions/custom-header.ts` if you like it; no model-cost impact

### Remove first
- `agent/extensions/web-fetch/`
- `agent/extensions/video-extract/`

### Remove unless actively used
- `agent/extensions/google-image-search/`
- `agent/extensions/youtube-search/`
- `agent/extensions/md-link.ts`
- `agent/extensions/memory.ts`
- `agent/extensions/filechanges/`
- `npm:pi-subagents` if you do not regularly use multi-agent workflows
- `npm:@ff-labs/pi-fff` if your repos are small or built-in `find`/`grep` are enough

### Change
- `agent/settings.json`: cheaper default model + lower default thinking.
- `agent/skills/orchestrator/SKILL.md`: remove “never explore directly”; make direct inspection the default for small tasks.
- `agent/extensions/bash-guard/index.ts`: allow read-only git commands without prompt.
- If keeping image search: make thumbnail/image return opt-in.

## Residual risks

- This is static inspection, not runtime measurement. Exact prompt-token cost depends on Pi’s tool/skill injection behavior.
- No git/shell commands were run by this reviewer.
- Some “remove” recommendations depend on actual usage frequency. If a tool is used daily, keep it and simplify defaults instead.