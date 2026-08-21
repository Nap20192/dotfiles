#!/bin/sh
# Smoke-test the nvim config: clean startup + tests/smoke.lua assertions.
set -e
cd "$(dirname "$0")/.."

err=$(nvim --headless "+qa!" 2>&1 | grep -vE '^\[ClaudeCode\]' || true)
if [ -n "$err" ]; then
    echo "FAIL startup produced errors:"
    echo "$err"
    exit 1
fi
echo "OK   clean startup"

nvim --headless "+luafile tests/smoke.lua" 2>&1
