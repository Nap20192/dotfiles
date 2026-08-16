# Code Context

## Files Retrieved
1. `agent/settings.json` (lines 1-12) - primary config: model/provider/thinking and package list.
2. `agent/npm/package.json` (lines 1-10) - resolved npm package dependencies from settings.
3. `agent/npm/node_modules/pi-web-access/package.json` (lines 1-49) - installed web package purpose and dependencies.
4. `agent/npm/node_modules/pi-web-access/index.ts` (lines 1660-2672, 2992-3338) - package registers web/search/fetch tools and UI commands.
5. `agent/npm/node_modules/@ff-labs/pi-fff/package.json` (lines 1-35) and `src/index.ts` (lines 556-1174) - fuzzy search tools and flags.
6. `agent/npm/node_modules/@dietrichgebert/ponytail/package.json` (lines 1-35), `pi-extension/index.js` (lines 63-172) - lazy-dev mode extension/skills and commands.
7. `agent/npm/node_modules/pi-subagents/package.json` (lines 1-70), `src/extension/index.ts` (lines 596-640), `src/extension/schemas.ts` (lines 38-317) - delegation tool and workflow schema surface.
8. `agent/extensions/bash-guard/index.ts` (lines 1-460) - local bash safety gate.
9. `agent/extensions/filechanges/index.ts` (lines 1-602) - local edit/write diff tracker and revert/accept commands.
10. `agent/extensions/web-fetch/package.json` (lines 1-13), `index.ts` (lines 1-626) - local URL fetch/PDF markdown extractor.
11. `agent/extensions/youtube-search/index.ts` (lines 1-330) - local yt-dlp YouTube search tool.
12. `agent/extensions/google-image-search/index.ts` (lines 1-174) - local Google Custom Search image tool.
13. `agent/extensions/video-extract/index.ts` (lines 1-1214) - local YouTube/local video extraction tool.
14. `agent/extensions/zz-read-only-mode.ts` (lines 1-160) - local read-only tool allowlist mode.
15. `agent/skills/orchestrator/SKILL.md` (lines 1-96) - orchestration/context hygiene rules.
16. `agent/skills/pdf-reader/SKILL.md` (lines 1-143) - PDF reading workflow scripts.
17. `agent/skills/reddit/SKILL.md` (lines 1-55) - Reddit JSON API workflow.
18. `agent/skills/stop-slop/SKILL.md` (lines 1-84) - prose cleanup checklist.

## Key Code

### Primary config
```json
// agent/settings.json lines 3-11
"defaultProvider": "openai-codex",
"defaultModel": "gpt-5.5",
"defaultThinkingLevel": "medium",
"packages": [
  "npm:pi-web-access",
  "npm:@ff-labs/pi-fff",
  "npm:@dietrichgebert/ponytail",
  "npm:pi-subagents"
]
```
Impact: high-capability default favors quality over cost/speed. Medium thinking is a reasonable default; bump down for routine edits, up only for hard design/debugging.

### Installed packages inventory
- `pi-web-access` (`agent/npm/node_modules/pi-web-access/package.json` lines 1-49): broad web package: web search, URL fetching, GitHub repo cloning, PDF extraction, YouTube/video analysis. Registers `web_search`, `source_check`, `fetch_content`, `get_search_content` and commands `/websearch`, `/curator`, `/google-account`, `/search` (`index.ts` lines 1660-3338).  
  - Efficiency: improves quality on external/current info; can add latency/cost and a large tool surface.  
  - Recommendation: **keep if web/current research is common; otherwise remove and rely on local `web_fetch` only**. Severity: medium cost/token risk due broad provider/tool descriptions.
- `@ff-labs/pi-fff` (`package.json` lines 1-35): fast fuzzy file/content search. Registers `grep`, `find`, `multiGrep` and commands `/fff-mode`, `/fff-health`, `/fff-rescan` (`src/index.ts` lines 556-1174).  
  - Efficiency: likely strong speed/token win for code exploration versus `find`/`grep` dumps.  
  - Recommendation: **keep**. Prefer this over more custom search helpers.
- `@dietrichgebert/ponytail` (`package.json` lines 1-35): lazy senior dev mode + skills; commands `/ponytail`, `/ponytail-review`, `/ponytail-audit`, `/ponytail-gain`, `/ponytail-debt`, `/ponytail-help` (`pi-extension/index.js` lines 63-172).  
  - Efficiency: improves simplicity and cost by discouraging overbuild; can underbuild if applied blindly.  
  - Recommendation: **keep**, but do not let it override explicit safety/validation needs.
- `pi-subagents` (`package.json` lines 1-70): delegation/workflow system. Registers `subagent` (`src/extension/index.ts` lines 596-640) with many workflow/chain/mission controls (`schemas.ts` lines 38-317).  
  - Efficiency: improves context hygiene and parallel scouting/review on complex tasks; harms speed/cost on small tasks.  
  - Recommendation: **keep only if multi-agent work is actually used**; otherwise remove. If kept, use scouts for exploration and avoid subagents for tiny edits. Severity: medium complexity/control risk.

### Local extensions inventory
- `agent/extensions/bash-guard/index.ts` lines 1-460: analyzes bash commands; blocks catastrophic commands in subagents, prompts in main session; covers `rm`, destructive git, disk ops, curl-to-shell, secrets exposure patterns.  
  - Impact: safety/control high positive; small latency only on risky bash.  
  - Recommendation: **keep**. Severity if removed: high safety regression.
- `agent/extensions/filechanges/index.ts` lines 1-602: tracks successful `edit`/`write`, stores baselines, shows diff UI, provides accept/decline commands.  
  - Impact: quality/safety positive; token-neutral, some runtime overhead on write/edit.  
  - Recommendation: **keep** if agents edit files. Prefer this over manual diff bookkeeping.
- `agent/extensions/web-fetch/index.ts` lines 1-626 and package lines 1-13: simple `web_fetch` URL-to-markdown tool using Readability/Turndown, PDFs via `unpdf`, Jina fallback. Limits: 30s timeout, 5MB HTML/text, 20MB PDF, first 100 PDF pages.  
  - Impact: useful, narrower than `pi-web-access`.  
  - Recommendation: **remove if keeping `pi-web-access`** because package `fetch_content` overlaps and is richer. **Keep instead of `pi-web-access`** if you only need URL/PDF fetch and want smaller surface. Severity: low duplicate-tool cost.
- `agent/extensions/youtube-search/index.ts` lines 1-330: `youtube_search` tool using external `yt-dlp`, metadata only, no download, 30s timeout.  
  - Impact: fast for YouTube discovery; external binary dependency.  
  - Recommendation: **remove unless YouTube search is frequent**; `pi-web-access`/web search can usually find videos. Severity: low maintenance/tool clutter.
- `agent/extensions/google-image-search/index.ts` lines 1-174: `google_image_search` using Google CSE credentials from env or `auth.json`, fetches inline thumbnails.  
  - Impact: quality positive for image tasks; tokens/cost increase due thumbnails; credentials/control burden.  
  - Recommendation: **remove unless image search is a real workflow**. Severity: medium token/privacy/credential surface.
- `agent/extensions/video-extract/index.ts` lines 1-1214: `video_extract` tool for YouTube/local video; frame extraction via `yt-dlp`/`ffmpeg`; deeper analysis via Gemini API (`gemini-3-flash-preview`) and Google API key.  
  - Impact: high quality on video tasks; high latency/cost and external/API dependency.  
  - Recommendation: **remove unless video analysis is frequent**. If kept, prefer frame-only mode as prompt guidelines already say. Severity: medium cost/complexity.
- `agent/extensions/zz-read-only-mode.ts` lines 1-160: `/read-only` command re-registers/allowlists only `read`, `grep`, `find`, `ls`; blocks all other tools while enabled.  
  - Impact: strong safety/control during review/scout work.  
  - Recommendation: **keep** if review-only sessions matter. Otherwise built-in tool discipline may be enough.

### Local skills inventory
- `agent/skills/orchestrator/SKILL.md` lines 1-96: parent-session rules: verify before implementing, delegate scouting/research/work, context hygiene, implementation discipline, verify before claiming done.  
  - Impact: quality/control positive for parent; can add ceremony and cost if triggered for small tasks.  
  - Recommendation: **keep for parent only**. Do not inject into child/subagent contexts. Severity: medium inefficiency if applied universally.
- `agent/skills/pdf-reader/SKILL.md` lines 1-143: PDF workflow using venv + PyMuPDF scripts; triage, extract text, selectively render images.  
  - Impact: quality positive for PDFs; setup/runtime overhead.  
  - Recommendation: **keep only if PDF work is common**. If `pi-web-access` PDF extraction is enough, remove this skill and scripts.
- `agent/skills/reddit/SKILL.md` lines 1-55: Reddit search/top/post via public JSON API, no key.  
  - Impact: useful niche research; low cost.  
  - Recommendation: **remove unless Reddit research is frequent**; web search can cover occasional needs.
- `agent/skills/stop-slop/SKILL.md` lines 1-84: prose style cleanup rules.  
  - Impact: improves prose quality; can waste tokens if applied to code tasks.  
  - Recommendation: **keep only if writing/editing prose is common**; otherwise remove.

## Architecture

Pi loads `agent/settings.json`, installs/loads npm packages from `agent/npm`, and auto-discovers local extensions under `agent/extensions`. Packages and local extensions both register tools/commands into the same tool namespace. Skills under `agent/skills/*/SKILL.md` add behavior when invoked/selected.

Data/control flow:
1. User request enters the model configured by `defaultProvider/defaultModel/defaultThinkingLevel`.
2. Available tools are the union of built-ins, npm package extensions, and local extensions.
3. Safety/control extensions (`bash-guard`, `read-only-mode`, `filechanges`) sit around tool use: bash calls can be blocked/prompted; read-only can shrink active toolset; edit/write results are diff-tracked.
4. Research/media extensions (`pi-web-access`, local `web_fetch`, YouTube/image/video tools, PDF/Reddit skills) expand task reach but increase tool descriptions, external calls, latency, credentials, and token outputs.
5. Behavioral packages/skills (`ponytail`, `orchestrator`, `stop-slop`) shape how much work the agent does and whether it delegates.

Main duplication:
- `pi-web-access` overlaps local `web-fetch` and parts of local `video-extract`/YouTube workflows.
- `pi-subagents` overlaps local `orchestrator` skill conceptually; one is the tool/runtime, the skill is policy.
- `pdf-reader` skill overlaps `pi-web-access`/local `web_fetch` PDF text extraction, but adds visual/math strategy.

## Efficiency assessment

### Speed
- Keep: `@ff-labs/pi-fff`, `filechanges`, `bash-guard`, `ponytail`.
- Slow only when used: `pi-web-access`, `video_extract`, `pdf-reader`, Google image search.
- Biggest speed drag: too many overlapping web/media tools causing tool-choice overhead and accidental expensive calls.

### Token/cost
- Highest cost risks: default `gpt-5.5` + medium thinking for all tasks; `video_extract` Gemini analysis; image thumbnails; broad web search/source-check outputs; subagent fanout.
- Token savers: `fff` search, `ponytail`, `read-only` for scouting/review, `get_search_content` style pagination in `pi-web-access`.

### Quality
- Quality wins: high-capability default model, `fff`, `filechanges`, `bash-guard`, `pi-web-access` for current info, `pdf-reader` for math/visual PDFs, `ponytail` for simpler implementations.
- Quality risks: removing all external research tools would make current-info tasks worse; overusing Ponytail can skip needed validation if misapplied.

### Safety/control
- Strong positives: `bash-guard`, `read-only-mode`, `filechanges`, subagent acceptance/control schemas.
- Risks: Google/Gemini credentials and web/video tools send data externally; subagents can multiply tool use and complexity; broad package tools enlarge the attack/mistake surface.

## Recommendations

### Keep
1. `@ff-labs/pi-fff` - clear speed/token win for code search.
2. `@dietrichgebert/ponytail` - keeps changes small; align with deletion/simple-default preference.
3. `agent/extensions/bash-guard` - high safety value.
4. `agent/extensions/filechanges` - edit accountability and easy revert.
5. `agent/extensions/zz-read-only-mode` - cheap, useful control for scouting/review.

### Choose one web stack
- Simple/default: **keep local `agent/extensions/web-fetch`, remove `npm:pi-web-access`** if you mostly fetch URLs/PDFs and want less surface.
- Research-heavy: **keep `npm:pi-web-access`, remove local `agent/extensions/web-fetch`** because `fetch_content` overlaps and the package adds search/source-check/storage.

Recommended lazy default: keep `pi-web-access` only if current web research is a normal part of work. Otherwise delete it and keep the local `web_fetch`.

### Remove unless used weekly
1. `agent/extensions/video-extract` - expensive, long, credentialed; use only for real video workflows.
2. `agent/extensions/google-image-search` - credentials + thumbnail tokens; use native/web search unless image selection is common.
3. `agent/extensions/youtube-search` - niche and depends on `yt-dlp`; web search covers occasional discovery.
4. `agent/skills/reddit` - niche.
5. `agent/skills/stop-slop` - useful only for prose-heavy work.
6. `agent/skills/pdf-reader` - keep only for math/academic PDFs; otherwise built-in/package PDF text extraction is simpler.

### Change
1. Consider lowering `defaultThinkingLevel` from `medium` to `low` for everyday coding, with manual escalation for hard tasks. Severity: medium cost/speed.
2. Keep `defaultModel: gpt-5.5` for hard/quality-sensitive work; use a cheaper model profile for scout/review/simple edits if Pi supports per-task overrides. Severity: medium cost.
3. Avoid applying `agent/skills/orchestrator` to subagents; it says “Not intended for subagents” and contains parent-only delegation policy. Severity: medium control/efficiency.
4. If retaining `pi-subagents`, cap fanout/concurrency by habit; use for exploration/review, not tiny edits. Severity: medium cost/control.

## Start Here
Open `agent/settings.json` first. It names the global model/thinking defaults and the package surface; then decide whether `npm:pi-web-access` or local `agent/extensions/web-fetch` should own web fetching.

## Supervisor coordination
No supervisor decision needed; no config files edited. Wrote this inventory artifact only.

## Acceptance