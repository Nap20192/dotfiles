## Review

### Correct
- `agent/settings.json:6-11` keeps package list explicit, so high-risk capabilities are easy to identify.
- `agent/extensions/zz-read-only-mode.ts:22,46,183-200` implements a real active-tool allowlist (`read`, `grep`, `find`, `ls`) and blocks other tool calls while enabled.
- `agent/extensions/bash-guard/index.ts:427-449` prompts/block-checks risky `bash` in main sessions; subagent mode also hard-blocks catastrophic patterns at `agent/extensions/bash-guard/index.ts:396-406`.
- Installed `pi-web-access` has materially safer fetch plumbing than the local `web-fetch`: SSRF validation is in `agent/npm/node_modules/pi-web-access/ssrf-protection.ts:169-209`, and `fetch_content` routes through it at `agent/npm/node_modules/pi-web-access/extract.ts:1001-1003`.

### Fixed
- None. Review-only task; no edits made.

### Blocker
- **High: duplicate local `web_fetch` bypasses the safer installed web access package.**  
  Evidence: `agent/extensions/web-fetch/index.ts:386` fetches arbitrary URLs directly; `agent/extensions/web-fetch/index.ts:517` only validates URL syntax; `agent/extensions/web-fetch/index.ts:342` falls back to sending the URL through `https://r.jina.ai/`; `agent/extensions/web-fetch/index.ts:424,441` reads response bodies after only checking `Content-Length`. No local/private IP SSRF guard was found in this extension.  
  **Safer minimal alternative:** remove `agent/extensions/web-fetch/` and use installed `pi-web-access` `fetch_content`.

- **High: `md-link` can create and mutate arbitrary filesystem paths, then auto-append assistant output.**  
  Evidence: absolute paths are accepted and relative paths resolve from `ctx.cwd` at `agent/extensions/md-link.ts:55-57`; missing directories/files are created at `agent/extensions/md-link.ts:60-62`; every final assistant message is appended at `agent/extensions/md-link.ts:137-161`.  
  **Safer minimal alternative:** remove it unless actively needed. If kept, restrict links to `ctx.cwd`, require existing `.md` files, and append only on explicit command.

- **High: `pi-subagents` is powerful and currently uncapped by local config.**  
  Evidence: installed in `agent/settings.json:10`; no `agent/extensions/subagent/config.json` was present; defaults include async-on behavior (`agent/npm/node_modules/pi-subagents/src/extension/config.ts:171-172`), depth default 2 (`agent/npm/node_modules/pi-subagents/src/shared/types.ts:2092,2146-2149`), top-level parallel max 8/concurrency 4 (`agent/npm/node_modules/pi-subagents/src/shared/types.ts:2068-2117`), per-run spawn default 64 (`agent/npm/node_modules/pi-subagents/src/shared/types.ts:2185-2195`), and default tool permission is allow (`agent/npm/node_modules/pi-subagents/src/runs/shared/permissions.ts:57-58`).  
  **Safer minimal alternative:** remove `npm:pi-subagents` unless delegation is essential. If kept, add a small config with `asyncByDefault:false`, `maxSubagentDepth:1`, `maxActiveAsyncRunsPerSession:1`, `maxSubagentSpawnsPerSession:8`, `maxSubagentSpawnsPerRun:8`, `timeoutMs`, `toolTimeoutMs`, and explicit permission rules for mutating tools.

### Note
- **Medium: `bash-guard` is weaker in headless subagents than in main UI sessions.** Main analysis flags `sed -i` and redirection at `agent/extensions/bash-guard/index.ts:213-216,281-285`, but subagent mode only checks `HEADLESS_BLOCKED` patterns at `agent/extensions/bash-guard/index.ts:363-391`.  
  **Change:** add headless blocks for redirection, `sed -i`, `perl -pi`, `truncate`, `mv -f`, `cp -f`, and risky git restore/checkout patterns.

- **Medium: `@ff-labs/pi-fff` can search outside the workspace.** Tool descriptions explicitly allow absolute, `~/`, and `../` paths outside the workspace at `agent/npm/node_modules/@ff-labs/pi-fff/src/index.ts:678,872`; aux finders route those paths at `agent/npm/node_modules/@ff-labs/pi-fff/src/aux-finders.ts:173-192`; home scanning defaults on at `agent/npm/node_modules/@ff-labs/pi-fff/src/index.ts:341-346`.  
  **Safer minimal alternative:** remove `npm:@ff-labs/pi-fff` and use built-in `find`/`grep`, or at least disable home scan with `FFF_ENABLE_HOME_SCAN=0`.

- **Medium: local `video_extract` can upload local video files to Google/Gemini.** Evidence: local paths resolve at `agent/extensions/video-extract/index.ts:197-210`; file bytes are read at `agent/extensions/video-extract/index.ts:541`; uploads happen via `uploadToFilesApi` at `agent/extensions/video-extract/index.ts:510-542`; Google key is pulled at `agent/extensions/video-extract/index.ts:1191`.  
  **Safer minimal alternative:** remove local `video-extract/`; use frame-only extraction or explicit user approval before any cloud upload.

- **Medium: `memory` encourages autonomous mutation.** Evidence: it creates `MEMORY.md` at `agent/extensions/memory.ts:63-66` and injects instructions to update it without asking at `agent/extensions/memory.ts:44-47,110-114`.  
  **Safer minimal alternative:** remove it, or keep disabled and require explicit `/memory` plus user-approved writes.

- **Low: PDF and Reddit skills are acceptable if explicit.** `pdf-reader` writes rendered pages to `/tmp` per `agent/skills/pdf-reader/scripts/pdf_render.py:27-38`; `reddit` sends queries to Reddit public JSON API in `agent/skills/reddit/reddit.js:45-48`. Use only for user-requested PDF/Reddit tasks.

## Keep / Remove / Change

- **Keep:** `zz-read-only-mode.ts`, `bash-guard/`, `ask-user-question.ts`, `context.ts`, `filechanges/`, `custom-header.ts`.
- **Remove first:** local `web-fetch/`, `md-link.ts`, local `video-extract/`.
- **Remove unless used daily:** `memory.ts`, `google-image-search/`, `youtube-search/`, `npm:@ff-labs/pi-fff`.
- **Keep with caps or remove:** `npm:pi-subagents`.
- **Keep as safer web default:** `npm:pi-web-access`, with browser-cookie/auth fetch disabled unless explicitly needed.

## Residual risks
- `agent/auth.json` contains OAuth credential fields. Do not run general coding agents with `/home/vnkjd/.pi` as cwd except for config review.
- Read-only mode blocks tool calls, but extension event handlers and user-invoked commands can still mutate state/files.
- Installed package code is broad; this was a targeted safety/control review, not a full supply-chain audit.