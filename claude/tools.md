# Claude Code tools I use

My set of Claude Code plugins, skills, and MCP servers, plus a one-shot installer.

Install everything: `./claude/install.sh`

## Plugins & skills

| Name | What it does | Marketplace (repo) | Install ref |
|------|--------------|--------------------|-------------|
| **ponytail** | "Laziest senior dev" mode — writes the least code that works | `DietrichGebert/ponytail` | `ponytail@ponytail` |
| **caveman** | Compresses agent output (talks like caveman) to cut tokens ~65% | `JuliusBrussee/caveman` | `caveman@caveman` |
| **frontend-design** | Anthropic's first-party skill for distinctive, non-"AI slop" UIs | `anthropics/claude-code` | `frontend-design@claude-code-plugins` |
| **mattpocock-skills** | Matt Pocock's full skill set (spec → tickets → TDD implement, etc.) — one plugin bundling all his skills | `mattpocock/skills` | `mattpocock-skills@mattpocock` |
| **superpowers** | obra's (Jesse Vincent) skill collection — brainstorming, planning, and disciplined workflow skills | `obra/superpowers` | `superpowers@superpowers-dev` |
| **andrej-karpathy-skills** | Karpathy-inspired skills bundle | `multica-ai/andrej-karpathy-skills` | `andrej-karpathy-skills@karpathy-skills` |

## MCP servers

| Name | What it does | Command / endpoint |
|------|--------------|--------------------|
| **chrome-devtools** | Drive & inspect a live Chrome (navigate, click, screenshot, console, perf) | `npx chrome-devtools-mcp@latest` |
| **github** | GitHub's official remote MCP server (repos, issues, PRs, actions) | `https://api.githubcopilot.com/mcp/` (HTTP) |

### Notes
- **chrome-devtools** needs Node.js ≥ 20.19 and a local Chrome install.
- **github** authenticates with a GitHub token. The installer uses `$GITHUB_PAT`, then `$GITHUB_TOKEN`, then `gh auth token` if the `gh` CLI is logged in.

## Manual equivalents

```sh
# Plugins
claude plugin marketplace add DietrichGebert/ponytail && claude plugin install ponytail@ponytail
claude plugin marketplace add JuliusBrussee/caveman  && claude plugin install caveman@caveman
claude plugin marketplace add anthropics/claude-code && claude plugin install frontend-design@claude-code-plugins
claude plugin marketplace add mattpocock/skills      && claude plugin install mattpocock-skills@mattpocock
claude plugin marketplace add obra/superpowers        && claude plugin install superpowers@superpowers-dev
claude plugin marketplace add multica-ai/andrej-karpathy-skills && claude plugin install andrej-karpathy-skills@karpathy-skills

# MCP servers (user scope = available in every project)
claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@latest
claude mcp add -s user --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer <YOUR_GITHUB_PAT>"
```
