## Review

### Correct
- `agent/settings.json:8-11` installs four high-impact packages: `pi-web-access`, `@ff-labs/pi-fff`, `@dietrichgebert/ponytail`, and `pi-subagents`.
- The setup has strong quality/safety primitives:
  - `bash-guard` blocks/prompts risky shell use (`agent/extensions/bash-guard/index.ts:87`, `:283-291`, `:363-401`).
  - `filechanges` tracks edit/write baselines and can revert accepted tool changes (`agent/extensions/filechanges/index.ts:538-569`, `:263-284`).
  - `ponytail` injects minimalism guidance before each agent turn (`agent/npm/node_modules/@dietrichgebert/ponytail/pi-extension/index.js:204-209`).
  - `pi-subagents` supplies scout/worker/reviewer/oracle roles (`agent/npm/node_modules/pi-subagents/README.md:59-66`).

### Blocker
- None found.

### High-value changes
1. **Remove duplicate local web/video tools if keeping `pi-web-access`.**
   - `pi-web-access` already provides `fetch_content` for readable pages, PDFs, GitHub repos, YouTube, local video, raw mode, and grounded answers (`agent/npm/node_modules/pi-web-access/index.ts:2326-2329`).
   - Local duplicates add tool-choice noise and maintenance:
     - `agent/extensions/web-fetch/index.ts:548-552`
     - `agent/extensions/video-extract/index.ts:1145-1179`
     - `agent/extensions/web-fetch/package.json:9-12`
   - Safety: local `web_fetch` falls back to Jina Reader (`agent/extensions/web-fetch/index.ts:14`, `:342`, `:534`) without the explicit remote-provider controls documented by `pi-web-access` (`agent/npm/node_modules/pi-web-access/README.md:249-253`).

2. **Set `pi-subagents` tool description to compact.**
   - Default is full (`agent/npm/node_modules/pi-subagents/src/extension/tool-description.ts:73-75`, `:184`).
   - Config supports compact mode (`agent/npm/node_modules/pi-subagents/docs/configuration.md:21-27`).
   - Benefit: less prompt/tool-description token overhead while preserving core safety guidance.

3. **Disable browser-cookie web access unless needed.**
   - Current config enables it: `web-search.json:2`.
   - `pi-web-access` docs say browser-cookie extraction is opt-in and may touch browser/Keychain data (`agent/npm/node_modules/pi-web-access/README.md:802`).
   - Recommendation: set `"allowBrowserCookies": false`; use explicit `authFetch` host profiles only when required.

4. **Resolve `pi-fff` vs read-only extension collision risk.**
   - `pi-fff` can replace/augment `find` and `grep` (`agent/npm/node_modules/@ff-labs/pi-fff/README.md:123-125`).
   - `zz-read-only-mode.ts` unconditionally re-registers built-in `read/grep/find/ls` (`agent/extensions/zz-read-only-mode.ts:61-86`), which can undermine `pi-fff` override mode.
   - Recommendation: keep read-only mode only if you use it; otherwise remove or change it to avoid re-registering tools while disabled.

---

## Package impact

| Package | Keep/remove/change | Speed | Token/cost | Quality | Safety/control |
|---|---|---:|---:|---:|---:|
| `npm:pi-web-access` | **Keep, but disable browser cookies; remove local web/video duplicates.** | Good: one tool covers search/fetch/PDF/GitHub/video. | Mixed: large tool surface, but `get_search_content` stores and slices content (`README.md:153`). | High: citations, source checking, GitHub cloning, PDFs/videos. | Good SSRF controls (`README.md:249`); cookie mode is risk if globally enabled. |
| `npm:@ff-labs/pi-fff` | **Keep for large repos; use `override` to reduce duplicate search tools. Remove for small/simple repos.** | High: pre-indexed, no subprocess grep/find (`README.md:9-12`). | Lower result defaults in code: grep 20/find 30 (`src/index.ts:35-36`). | Better discovery via fuzzy/frecency; possible noise if fuzzy weak. | Local only, no network/telemetry (`README.md:150-152`). |
| `npm:@dietrichgebert/ponytail` | **Keep.** | Faster decisions by biasing to deletion/simple defaults. | Adds system-prompt tokens every turn (`pi-extension/index.js:204-209`) but can reduce implementation/review churn. | Usually improves code quality for this user's preferences. | Risk: can underbuild if requirements truly need complexity; prompt has explicit safety exceptions (`skills/ponytail/SKILL.md:90-107`). |
| `npm:pi-subagents` | **Keep, change to compact description. Use deliberately.** | Slower per delegated task, faster on broad investigations/reviews. | High unless compact: full description is long (`tool-description.ts:18-27`). | High for scout/reviewer/oracle separation (`README.md:59-66`). | Good one-writer and async guidance (`tool-description.ts:9-16`). |

---

## Local extension impact

| Extension | Recommendation | Benefit | Noise/risk |
|---|---|---|---|
| `agent/extensions/ask-user-question.ts` | **Keep.** | Prevents guessing on material ambiguity (`:542-549`); serializes UI prompts safely (`:531-537`). | Can slow work if overused; UI-only fallback returns unavailable (`:568-569`). |
| `agent/extensions/bash-guard/` | **Keep.** | Strong safety on risky bash/git/redirection/pipes (`index.ts:87`, `:283-291`, `:363-401`). | Prompts on any git command, so it can slow routine checks. |
| `agent/extensions/context.ts` | **Keep.** | `/context` shows cost/cache/context pressure (`:77`, `:427-428`, `:457-469`). | Estimates tokens roughly by chars/4 (`:43-45`); advisory only. |
| `agent/extensions/custom-header.ts` | **Remove.** | Cosmetic only. | Hides keybinding hints by returning only `logo` after building hints (`:50-73`); no answer/code quality gain. |
| `agent/extensions/filechanges/` | **Keep.** | Tracks tool-made edits and can revert (`index.ts:538-569`, `:263-284`). | Stores original file contents in session custom entries (`:564-569`); privacy/session-size tradeoff. |
| `agent/extensions/google-image-search/` | **Remove unless you actively use Google CSE image search.** | Useful for visual selection with thumbnails (`index.ts:79-87`). | Dead/noisy without credentials (`:21-22`, `:65`); image blocks raise token cost. |
| `agent/extensions/md-link.ts` | **Remove unless Obsidian-linked editing is core workflow.** | Can edit via markdown and send diffs (`:94-122`). | Appends assistant output to linked files (`:137-161`), causing duplicate context/file churn. |
| `agent/extensions/memory.ts` | **Keep disabled or remove. Prefer remove for simple config.** | Long-lived project memory when deliberately enabled. | Injects autonomous read/update `MEMORY.md` prompt (`:38`, `:110-114`), causing stale-memory and repo-noise risk. |
| `agent/extensions/video-extract/` | **Remove if `pi-web-access` stays.** | Standalone frame/video extraction. | Duplicates `fetch_content`; uses Gemini preview default (`:13`) and external `yt-dlp`/`ffmpeg` paths (`:273`, `:303`, `:383`). |
| `agent/extensions/web-fetch/` | **Remove if `pi-web-access` stays.** | Simple readable web/PDF fetch. | Duplicates `fetch_content`; remote Jina fallback (`:14`, `:342`, `:534`); local dependency tree duplicates `pi-web-access` deps. |
| `agent/extensions/youtube-search/` | **Optional: keep only if YouTube discovery is common.** | Structured YouTube metadata via `yt-dlp` (`index.ts:133-143`, `:203-209`). | Requires external CLI; otherwise failures/noise (`:217-245`). |
| `agent/extensions/zz-read-only-mode.ts` | **Change or remove if using `pi-fff override`; otherwise keep.** | Hard-enforced read/grep/find/ls mode (`:22`, `:46`, `:190-200`). | Unconditionally re-registers built-in grep/find (`:61-86`), likely conflicts with search tooling. |

---

## Local skill impact

| Skill | Recommendation | Benefit | Noise/risk |
|---|---|---|---|
| `agent/skills/orchestrator/SKILL.md` | **Change/soften.** | Good verification discipline (`:10`, `:72`). | Over-delegates: “Never explore a codebase by reading files yourself” (`:32-39`) can waste time/cost. Also references `safe_bash` (`:19`) while installed worker uses `bash`. |
| `agent/skills/pdf-reader/SKILL.md` | **Keep.** | Token-efficient PDF triage and selective rendering (`:41`, `:57-65`). | Requires venv/PyMuPDF setup (`:12-21`). |
| `agent/skills/reddit/SKILL.md` | **Remove unless Reddit research is frequent.** | No API key, public JSON (`:3`, `:8`). | Narrow use; Reddit search is noisy/rate-limited (`:50-51`). |
| `agent/skills/stop-slop/SKILL.md` | **Keep for prose; do not use for code reviews by default.** | Improves writing/directness (`:3`, `:10-16`). | Rigid prose rules can harm technical clarity if applied blindly (`:32-40`, `:57`). |

---

## Recommended final trim

**Keep**
- `pi-web-access`
- `@ff-labs/pi-fff` only if large-repo search matters
- `@dietrichgebert/ponytail`
- `pi-subagents` with compact description
- `ask-user-question`, `bash-guard`, `context`, `filechanges`
- `pdf-reader`, `stop-slop`

**Remove or disable**
- `custom-header`
- local `web-fetch/`
- local `video-extract/`
- `google-image-search/` unless credentials/use case exist
- `md-link.ts` unless actively used
- `memory.ts` unless long-lived project memory is intentional
- `reddit` skill unless frequent
- `youtube-search` unless frequent

**Change**
- `web-search.json`: set `"allowBrowserCookies": false` unless explicitly needed.
- `pi-subagents`: set `toolDescriptionMode: "compact"`.
- `pi-fff`: use `override` if kept; otherwise remove it.
- `orchestrator` skill: replace “never read files yourself” with “use scouts for broad exploration,” and update `safe_bash` wording.

---

## Residual risks

- I inspected files only; no shell/test/git commands were run.
- I did not verify actual Pi extension load order, so the `pi-fff`/read-only conflict is a code-backed risk, not a runtime trace.
- I did not inspect private credentials beyond `web-search.json`.