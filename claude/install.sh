#!/usr/bin/env bash
#
# Install my Claude Code plugins, skills, and MCP servers.
# Idempotent: safe to re-run. See ./tools.md for the full list.
#
set -euo pipefail

if ! command -v claude >/dev/null 2>&1; then
  echo "error: 'claude' CLI not found on PATH. Install Claude Code first." >&2
  exit 1
fi

# --- Symlink config from dotfiles ------------------------------------------
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
echo "==> Linking config from $DOTFILES"
mkdir -p ~/.claude
for pair in \
  "$DOTFILES/.claude/settings.json ~/.claude/settings.json" \
  "$DOTFILES/.claude/commands      ~/.claude/commands" \
  "$DOTFILES/.claude/hooks         ~/.claude/hooks" \
  "$DOTFILES/.claude/skills        ~/.claude/skills" \
  "$DOTFILES/.agents               ~/.agents"; do
  read -r src dst <<<"$pair"
  dst="${dst/#\~/$HOME}"
  [ -e "$dst" ] && [ ! -L "$dst" ] && { echo "  ! $dst exists and is not a symlink, skipping"; continue; }
  ln -sfn "$src" "$dst"
  echo "--- $dst -> $src"
done

# --- Plugins & skills -------------------------------------------------------
# Each entry: "<marketplace-repo> <plugin-ref>"
plugins=(
  "DietrichGebert/ponytail ponytail@ponytail"
  "JuliusBrussee/caveman   caveman@caveman"
  "anthropics/claude-code  frontend-design@claude-code-plugins"
  "mattpocock/skills       mattpocock-skills@mattpocock"
  "obra/superpowers        superpowers@superpowers-dev"
  "multica-ai/andrej-karpathy-skills andrej-karpathy-skills@karpathy-skills"
)

echo "==> Installing plugins & skills"
for entry in "${plugins[@]}"; do
  read -r repo ref <<<"$entry"
  echo "--- $ref (from $repo)"
  claude plugin marketplace add "$repo" 2>/dev/null || true   # no-op if already added
  claude plugin install "$ref" || echo "  ! failed to install $ref (continuing)"
done

# --- MCP servers ------------------------------------------------------------
echo "==> Installing MCP servers (user scope)"

# chrome-devtools: local stdio server via npx
if claude mcp get chrome-devtools >/dev/null 2>&1; then
  echo "--- chrome-devtools already configured, skipping"
else
  echo "--- chrome-devtools"
  claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@latest \
    || echo "  ! failed to add chrome-devtools (continuing)"
fi

# github: official remote HTTP server, needs a token
GH_TOKEN="${GITHUB_PAT:-${GITHUB_TOKEN:-}}"
if [ -z "$GH_TOKEN" ] && command -v gh >/dev/null 2>&1; then
  GH_TOKEN="$(gh auth token 2>/dev/null || true)"
fi

if claude mcp get github >/dev/null 2>&1; then
  echo "--- github already configured, skipping"
elif [ -z "$GH_TOKEN" ]; then
  echo "--- github: SKIPPED — no token found."
  echo "    Set GITHUB_PAT (or GITHUB_TOKEN), or run 'gh auth login', then re-run this script."
else
  echo "--- github"
  claude mcp add -s user --transport http github https://api.githubcopilot.com/mcp/ \
    --header "Authorization: Bearer ${GH_TOKEN}" \
    || echo "  ! failed to add github (continuing)"
fi

echo
echo "==> Done. Verify with:  claude plugin list   and   claude mcp list"
