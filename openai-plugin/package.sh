#!/usr/bin/env bash
# Pack the skills-only OpenAI plugin into a ZIP for upload at https://platform.openai.com/plugins.
# Usage: ./openai-plugin/package.sh [zip-name] (default: fibery-skills-openai-<version>)
# The ZIP is written to ~/Desktop.

set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: $0 [zip-name] (default: fibery-skills-openai-<version>)"
  exit 0
fi
if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [zip-name]" >&2
  exit 1
fi

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$PLUGIN_DIR")"
VERSION=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$PLUGIN_DIR/.codex-plugin/plugin.json")
NAME="${1:-fibery-skills-openai-$VERSION}"
OUT="$HOME/Desktop/${NAME%.zip}.zip"

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

# Root plugin.json and mcp.json stay out: OpenAI would take identity and an MCP server from them.
cp -R "$PLUGIN_DIR/.codex-plugin" "$PLUGIN_DIR/assets" "$STAGE/"
cp -R "$REPO_DIR/skills" "$STAGE/skills"
cp -R "$PLUGIN_DIR/skills/." "$STAGE/skills/"
cp "$REPO_DIR/LICENSE" "$STAGE/"

rm -f "$OUT"
(cd "$STAGE" && zip -q -r -X "$OUT" . -x '*.DS_Store' '__MACOSX/*')
echo "created $OUT"
