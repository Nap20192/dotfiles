# Config-efficiency synthesis

Inherited decisions:
- No config/code edits.
- Rank by impact.
- Prefer `keep/remove/change`.
- Preserve safety/control unless cost is clearly wasteful.
- Choose one web/media stack; avoid duplicate tools.

## Ranked recommendations

### 1. Change default model/thinking — **High impact**
**Path:** `agent/settings.json`  
**Current:** `defaultModel: gpt-5.5`, `defaultThinkingLevel: medium`

**Change:** use a cheaper/faster daily default and reserve `gpt-5.5` + medium/high thinking for hard tasks.

Why: all reports agree this is the largest always-on latency/cost driver.

---

### 2. Remove duplicate local web/video stack if keeping `pi-web-access` — **High impact**
**Keep:** `npm:pi-web-access`  
**Remove:**
- `agent/extensions/web-fetch/`
- `agent/extensions/video-extract/`

Why: `pi-web-access` already covers fetch/PDF/GitHub/video workflows. Local `web-fetch` also has weaker SSRF/privacy posture and Jina fallback; local `video-extract` adds Gemini/API/upload cost.

---

### 3. Cap or remove subagents/orchestrator defaults — **High impact**
**Paths:**
- `agent/settings.json`
- `agent/skills/orchestrator/SKILL.md`
- `npm:pi-subagents`

**Change:** keep `pi-subagents` only if multi-agent workflows are genuinely used. If kept:
- use compact tool description
- reduce async/fanout defaults
- soften orchestrator rule from “never explore directly” to “use scouts for broad/uncertain work”

Why: subagents are excellent for broad reviews, but expensive for ordinary scoped edits.

---

### 4. Keep safety/control primitives — **High impact**
**Keep:**
- `agent/extensions/bash-guard/`
- `agent/extensions/filechanges/`
- `agent/extensions/zz-read-only-mode.ts`
- `agent/extensions/context.ts`
- `agent/extensions/ask-user-question.ts`

**Change:** allow read-only git commands in `bash-guard` without prompt.

Why: these prevent destructive mistakes with low ongoing cost.

---

### 5. Remove rare media/search tools unless used weekly — **Medium impact**
**Remove unless active workflow:**
- `agent/extensions/google-image-search/`
- `agent/extensions/youtube-search/`
- `agent/extensions/md-link.ts`
- `agent/extensions/memory.ts`
- `agent/skills/reddit/`
- `agent/skills/stop-slop/`

Why: niche tool schemas, credentials, thumbnails, autonomous writes, or workflow clutter.

---

### 6. Keep `@ff-labs/pi-fff`, but avoid duplicate search surfaces — **Medium impact**
**Path:** `agent/settings.json`

**Keep** for large repos.  
**Change/remove** if repos are small or if `zz-read-only-mode.ts` conflicts with FFF override behavior.

Why: strong speed/token win for repo search, but duplicate `grep/find` surfaces can add tool-choice noise.

---

### 7. Keep Ponytail — **Low/Medium positive impact**
**Path:** `agent/settings.json`

**Keep:** `npm:@dietrichgebert/ponytail`

Why: small prompt overhead, but usually reduces overbuild, code size, review churn, and output length.

---

## Recommended final state

### Keep
- `npm:pi-web-access`
- `npm:@dietrichgebert/ponytail`
- `npm:@ff-labs/pi-fff` if large-repo work is common
- `npm:pi-subagents` only with compact/capped defaults
- `bash-guard`
- `filechanges`
- `zz-read-only-mode`
- `context`
- `ask-user-question`
- `pdf-reader` only if hard PDFs are common

### Remove first
- `agent/extensions/web-fetch/`
- `agent/extensions/video-extract/`
- `agent/extensions/md-link.ts`

### Remove unless used weekly
- `agent/extensions/google-image-search/`
- `agent/extensions/youtube-search/`
- `agent/extensions/memory.ts`
- `agent/skills/reddit/`
- `agent/skills/stop-slop/`
- `agent/extensions/custom-header.ts`

### Change
- `agent/settings.json`: cheaper/faster default model; lower default thinking.
- `agent/skills/orchestrator/SKILL.md`: direct read/grep first for small tasks.
- `pi-subagents`: compact tool description and lower fanout.
- `bash-guard`: allow read-only git commands.
- `pi-web-access`: disable browser cookies unless explicitly needed.

## Residual risks
- Usage frequency is unknown; weekly/daily workflow should decide final removals.
- Static review only; no runtime benchmarks were run.
- Extension load order may affect `pi-fff` and read-only mode behavior.
- Browser-cookie/auth/web/video tools can expose local/private data if left broadly enabled.

## Final task split

- **Inventory:** mapped installed packages, local extensions, skills, overlaps, and primary config.
- **Speed:** ranked latency sources: model/thinking, subagents, web/media tools, duplicate fetch/video paths.
- **Cost:** ranked token/API/tool-schema costs: premium default model, duplicate tools, image/video outputs, subagent fanout.
- **Quality:** checked which tools improve correctness and where simplification would hurt quality.
- **Safety:** identified highest control/privacy risks: local `web-fetch`, `md-link`, uncapped subagents, video uploads, broad search paths.
- **Synthesis/oracle:** reconciled the reports into one keep/remove/change plan ranked by impact.